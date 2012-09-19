require 'lib/coordinate'

class Coordinates
  attr_accessor :coordinates
  include Enumerable

  def initialize(policy, date)
    @coordinates = policy.map { |interval| Coordinate.new(interval, date) }
  end

  def keep?
    @coordinates.any? {|c| c.keep? }
  end

  def each(&block); @coordinates.each(&block) end

end
