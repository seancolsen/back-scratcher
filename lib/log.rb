require 'singleton'

module Log

  def self.setup
    puts "setup logging"
    @@DEBUG = true
  end

  def self.debug(msg)
    puts msg if @@DEBUG
  end

  def self.info(msg)
    puts msg
  end

  def self.warn(msg)

  end

  def self.error(msg)

  end
  
  def self.fatal(msg)

  end


end
