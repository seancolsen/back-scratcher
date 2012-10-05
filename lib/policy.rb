class Policy
  attr_accessor :intervals
  include Enumerable

  def initialize(intervals)
    # expects an array of interval phrases 
    @intervals = intervals.map {|i| Interval.new(i)} 
  end
  
  def running_period
    self.intervals.min.period
  end

  def each(&block); @intervals.each(&block) end

  def record_capacity
    lifetime_carryover = 0
    @intervals.sort_by(&:lifetime).map do |interval|
      previous_lifetime = lifetime_carryover 
      lifetime_carryover = interval.lifetime
      capactiy = interval.record_capacity(previous_lifetime)
    end.inject(:+)
  end

end
