require 'lib/policy'
require 'lib/vault'

class Job
  attr_accessor :name, :host, :user, :policy, :source, :type, :vault

  def initialize(name, settings)
    @name = name
    @policy = Policy.new(settings['keep-every']) 
    @source = settings['source'] 
    @type = @source['database'] ? :database : :filesystem
    @vault = Vault.new(@name)
    @user = settings['user']
    @host = settings['host']
  end

  def self.load_from_yaml(yaml_file)
    # returns an array of job objects 
    YAML.load_file(yaml_file).map do |name, settings|
      Job.new(name, settings) 
    end
  end

  def needs_backup?
    if @vault.last_modified == nil
      true
    else
      Time.now - @vault.last_modified > @policy.running_period.seconds
    end
  end

  def backup
    @type == :database ? self.backup_database : self.backup_filesystem
  end

  def backup_database
    mysqldump = "mysqldump 
                 --skip-dump-date
                 -u#{@source['user']} 
                 -p#{@source['password']}
                   #{@source['database']}".gsub(/\s+/,' ').strip
    @vault.ensure_exists 
    filename = File.join(@vault.directory,
        Time.now.strftime('%Y-%m-%dT%H-%M-%S_0.sql.gz') )
    `ssh #{@user}@#{@host} '#{mysqldump} | gzip -c' > #{filename} `
    @vault.add_record(filename)
  end 

  def backup_filesystem
    #TODO
  end 

  def no_backup
    #TODO log info here
  end

  def try_backup; self.needs_backup? ? self.backup : self.no_backup end

end

