class Size
  attr_accessor :bytes
  include Comparable
                 
  def initialize(bytes); @bytes = bytes.to_i end
  
  def to_i; @bytes end

  def to_s; @bytes.to_s end

  def zero?; @bytes == nil or @bytes == 0 end

  def <=>(other); 
    other = Size.new(other.to_i) unless other.class == Size
    self.bytes <=> other.bytes
  end

end
