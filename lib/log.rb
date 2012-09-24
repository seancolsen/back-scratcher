require 'singleton'

module Log

  def self.setup
    @@DEBUG = true
    @@VERBOSE = false
  end

  def self.be_verbose
    @@VERBOSE = true
  end

  def self.debug(msg)
    puts msg if @@DEBUG
  end

  def self.verbose(msg)
    puts msg if @@VERBOSE
  end

  def self.info(msg)
    puts msg
  end

  def self.warn(msg)
    puts 'WARNING ' + msg.to_s
  end

  def self.error(msg)
    puts 'ERROR!! ' + msg.to_s
  end
  
  def self.fatal(msg)
    puts 'FATAL ERROR!! ' + msg.to_s
    exit 
  end

end
