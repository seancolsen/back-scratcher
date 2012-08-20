require 'lib/policy'
require 'lib/vault'

class Job
  attr_accessor :name, :host, :policy, :source, :type, :vault

  def initialize(name, settings)
    @name = name
    @policy = Policy.new(settings['keep-every']) 
    @source = settings['source'] 
    @type = @source['database'] ? :database : :filesystem
    @vault = Vault.new(@name)
  end

  def running_period
    self.policy.running_period
  end

  def self.load_from_yaml(yaml_file)
    # returns an array of job objects 
    YAML.load_file(yaml_file).map do |name, settings|
      Job.new(name, settings) 
    end
  end

end

