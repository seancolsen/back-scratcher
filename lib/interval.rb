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

  def record_capacity(lifetime_reduction = 0)
    ( (@lifetime - lifetime_reduction) / @period ).ceil.seconds
  end

end
