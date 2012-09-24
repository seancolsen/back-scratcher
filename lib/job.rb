require 'lib/policy'
require 'lib/vault'
require 'yaml'

class Job
  attr_accessor :name, :host, :user, :policy, :source, :type, :vault,
                :collection_path

  # Number of seconds before a backup is scheduled that it's okay for us 
  # make one.
  SLACK = 120 

  def initialize(name, settings, collection_path)
    @name = name
    @collection_path = collection_path
    @policy = Policy.new(settings['keep-every']) 
    @source = settings['source'] 
    @type = @source['database'] ? :database : :filesystem
    @vault = Vault.new(File.join(@collection_path,'vault',@name), @policy) 
    @user = settings['user']
    @host = settings['host']
  end

  def needs_backup?
    if @vault.last_modified == nil
      true
    else
      Time.now - @vault.last_modified > @policy.running_period.seconds - SLACK
    end
  end

  def backup
    Log.info("backing up #{@name} ")
    @vault.ensure_exists 
    dest_file = self.new_record_path
    if @type == :database 
      self.backup_database(dest_file)
    else
      self.backup_filesystem(dest_file)
    end
    @vault.add_record(dest_file)
  end

  def new_record_path
    ext = @type == :database ? '.sql.gz' : ''
    File.join(@vault.directory, Time.now.strftime('%Y-%m-%dT%H-%M-%S_0'+ext) )
  end

  def backup_database(dest_file)
    dump = <<-CMD.flatten
      mysqldump 
      --skip-dump-date
      -u#{@source['user']} 
      -p#{@source['password']}
        #{@source['database']}
      CMD
    `ssh #{@user}@#{@host} '#{dump} | gzip -c' > "#{dest_file}" `
  end 

  def backup_filesystem(dest_file)
    ignore = @source['ignore'].map{|i| "--exclude='#{i}' "}.reduce(:+)
    link_dest = if @vault.latest_record
      "--link-dest='#{File.expand_path(@vault.latest_record.path)}' "
      else ''
      end
    source_directory = @source['directory'].chomp('/').concat('/')
    cmd = <<-CMD.flatten
      rsync -avzx #{ignore} #{link_dest} 
      "#{@user}@#{@host}:'#{source_directory}'"
      "#{dest_file}"
      CMD
    puts cmd
    `#{cmd}`
  end 

  def try_backup
    if self.needs_backup? 
      self.backup 
    else
      Log.verbose("Skipping #{@name}. Last backed up #{@vault.last_modified}")
    end 
  end

  def prune(opts); @vault.prune(opts) end

end

