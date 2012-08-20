require 'lib/duration'

class Interval
  include Comparable
  attr_accessor :period, :lifetime 

  def initialize(phrase)
    period, lifetime = phrase.split(' for ') 
    @period = Duration.new(period)
    @lifetime = Duration.new(lifetime)
  end
  
  def <=>(other)
    self.period.seconds <=> other.period.seconds
  end

end
