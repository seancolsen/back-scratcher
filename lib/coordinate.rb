class Coordinate < Interval
  attr_accessor :ordinal, :keep

  ORIGIN = Time.local(2010)
  
  def initialize(interval, date)
    super(interval)
    @date = date
    @ordinal = ( (@date - ORIGIN) / @period.seconds ).floor
    @keep = false
  end

  def sheltered?
    (Time.now - @date) <= @lifetime.seconds
  end

  def keep!; @keep = true end

  def keep?; @keep end

end
