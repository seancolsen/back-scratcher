
class Interval
  attr_accessor :period, :lifetime 

  def initialize(phrase)
    period, lifetime = phrase.split(' for ') 
    @period = Duration.new(period)
    @lifetime = Duration.new(lifetime)
  end

end
