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

  def self.load_from_yaml(yaml_file)
  end

  def self.load_from_collection_path(path)
    # returns an array of job objects 
    yaml_file = File.join(path,'jobs.yaml')
    if !File.exists?(yaml_file)
      Log.fatal("Jobs configuration file not found at #{yaml_file}")
    end
    YAML.load_file(yaml_file).map do |name, settings|
      self.new(name, settings, path ) 
    end
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
    #@vault.add_record(dest_file)
  end

  def new_record_path
    ext = @type == :database ? '.sql.gz' : ''
    File.join(@vault.directory, Time.now.strftime('%Y-%m-%dT%H-%M-%S_0'+ext) )
  end

  def backup_database(dest_file)
    dump = "mysqldump 
            --skip-dump-date
            -u#{@source['user']} 
            -p#{@source['password']}
              #{@source['database']}".gsub(/\s+/,' ').strip
    `ssh #{@user}@#{@host} '#{dump} | gzip -c' > #{dest_file} `
  end 

  def backup_filesystem(dest_file)
    cmd = "rsync -azx #{@user}@#{@host}:#{@source['directory']} #{dest_file}"
    #puts cmd
  end 

  def try_backup
    if self.needs_backup?; self.backup end 
  end

  def prune(opts); @vault.prune(opts) end

end

