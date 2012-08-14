
class Policy
  attr_accessor :intervals

  def initialize(intervals)
    # expects an array of interval phrases 
    @intervals = intervals.map {|i| Interval.new(i)} 
  end

end

