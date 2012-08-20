require 'lib/interval'

class Policy
  attr_accessor :intervals

  def initialize(intervals)
    # expects an array of interval phrases 
    @intervals = intervals.map {|i| Interval.new(i)} 
  end
  
  def running_period
    self.intervals.min.period
  end

end

