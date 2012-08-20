
class Duration
  attr_accessor :seconds
  include Comparable

  UNITS = { :second => 1, 
            :minute => 60,
            :hour   => 60*60, 
            :day    => 60*60*24, 
            :year   => 60*60*24*365 }

  def initialize(description)
    if description.eql?('eternity') 
      @seconds = 0
    else
      value, units = description.to_s.split
      multiplier = units.nil? ? 1 : UNITS[units.downcase.chomp('s').to_sym]
      if multiplier.nil? then raise "Unknown duration units '#{units}'" end    
      @seconds = value.to_i * multiplier
    end
  end

  def <=>(other)
    self.seconds <=> other.seconds
  end

end 

