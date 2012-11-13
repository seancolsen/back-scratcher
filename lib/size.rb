require 'file_util'

class Size
  attr_accessor :bytes
  include Comparable
                 
  UNITS = ['bytes','kB','MB','GB'].each_with_index.map{|x,i| [x,10**(i*3)]}

  def initialize(bytes); @bytes = bytes.to_i end

  def self.of_directory(dir)
    Size.new(FileUtil.directory_size(dir))
  end

  def to_f; @bytes.to_f end

  def to_i; @bytes.to_i end
  
  def to_s; @bytes.to_s end

  def zero?; @bytes == nil or @bytes == 0 end

  def <=>(other); 
    other = Size.new(other.to_i) unless other.class == Size
    @bytes <=> other.bytes
  end

  def +(other)
    other = other.bytes if other.class == Size 
    Size.new(@bytes + other) 
  end

  def /(other)
    other = other.bytes if other.class == Size 
    Size.new(@bytes / other.to_f) 
  end

  def approx_human_description
    units, value = UNITS.map{|i| [i[0], @bytes.to_f/i[1]]}.
                         find_all{|i| i[1] >= 1}.sort_by(&:last).first
    value = if value < 10 then ((value*100).round).to_f/100 
                          else ((value*10 ).round).to_f/10 end
    "#{value} #{units}"
  end

end
