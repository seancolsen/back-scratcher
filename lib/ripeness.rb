class Ripeness
  attr_accessor :score, :coordinates

  def initialize(policy, date)
    @coordinates = Coordinates.new(policy, date)
  end

  def coordinate(criteria)
    period = case criteria
      when Interval then criteria.period
      when Duration then criteria
      else Log.fatal("unable to fetch coordinate given #{criteria}")
    end
    c = @coordinates.select {|c| c.period == period }.first
    Log.fatal("no coordinate found matching #{criteria.inspect}") unless c
    c
  end

end
