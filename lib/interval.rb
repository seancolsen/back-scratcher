require 'lib/duration'

class Interval
  include Comparable
  attr_accessor :period, :lifetime 

  def initialize(input)
    if input.class == Interval
      @period = input.period
      @lifetime = input.lifetime
    else
      period, lifetime = input.split(' for ') 
      @period = Duration.new(period)
      @lifetime = Duration.new(lifetime)
    end
  end
  
  def <=>(other)
    self.period.seconds <=> other.period.seconds
  end

end
