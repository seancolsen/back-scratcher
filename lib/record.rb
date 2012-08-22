require 'lib/size'

class Record
  attr_accessor :date, :size, :path, :file, :type
  include Comparable

  PATTERN = /^(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d)-(\d\d)-(\d\d)_(\d+)(.*)$/

  def initialize(path)
    @path = path
    @file = File.basename(path)
    year,month,day,hour,minute,second,size,rest = PATTERN.match(@file).captures
    @date = Time.local(year,month,day,hour,minute,second)
    @size = Size.new(size)
    @type = self.directory? ? :directory : :file
    if @size == 0; self.update_size end
  end

  def directory?; File.directory?(@path) end

  def update_size
    @size = self.real_size
    @file = @file.gsub(PATTERN,'\1-\2-\3T\4-\5-\6_'+@size+'\8')
    oldpath = @path
    @path = File.join(File.dirname(@path),@file)
    File.rename(oldpath,@path)
  end

  def directory_size; `du -s #{@path}`.split("\t")[0].to_i end

  def file_size; File.stat(@path).size end

  def real_size; self.directory? ? self.directory_size : self.file_size end

  def self.from_dir_contents(directory)
    Dir.glob(File.join(directory,'*')).map do |file|
      Record.new(file) 
    end
  end

  def <=>(other)
    self.date <=> other.date
  end

end
