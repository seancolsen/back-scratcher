require 'lib/size'

class Record
  attr_accessor :date, :size, :path, :file
  include Comparable

  def initialize(path)
    @path = path
    @file = File.basename(path)
    pattern = /(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d)-(\d\d)-(\d\d)_(\d+)/
    year,month,day,hour,minute,second,size = pattern.match(@file).captures
    @date = Time.local(year,month,day,hour,minute,second)
    @size = Size.new(size)
  end

  def self.from_dir_contents(directory)
    Dir.glob(File.join(directory,'*')).map do |file|
      Record.new(file) 
    end
  end

  def <=>(other)
    self.date <=> other.date
  end

end
