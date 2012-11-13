require 'file_util'

class Record
  attr_accessor :date, :size, :path, :file, :type, :ripeness
  include Comparable

  PATTERN = /^(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d)-(\d\d)-(\d\d)_(\d+)(.*)$/

  def initialize(path)
    @path = path
    @file = File.basename(path)
    year,month,day,hour,minute,second,size,rest = PATTERN.match(@file).captures
    @date = Time.local(year,month,day,hour,minute,second)
    @size = Size.new(size)
    @type = self.directory? ? :directory : :file
    if @size.zero?; self.update_size end
  end

  def directory?; File.directory?(@path) end

  def substantial?; @size > 0 end
  
  def update_size
    @size.bytes = self.real_size
    @file = @file.gsub(PATTERN, '\1-\2-\3T\4-\5-\6_' + @size.to_s + '\8')
    oldpath = @path
    @path = File.join(File.dirname(@path),@file)
    File.rename(oldpath,@path)
    rescue
      Log.error("unable to update size for #{@path}")
  end

  def file_size
   File.stat(@path).size 
    rescue
      Log.error("unable to determine file size of #{@path}")
  end

  def real_size; self.directory? ? FileUtil.directory_size(@path) : self.file_size end

  def create_ripeness(policy)
    @ripeness = Ripeness.new(policy, @date)
  end

  def self.from_dir_contents(directory)
    Dir.glob(File.join(directory,'*')).map do |file|
      Record.new(file) 
    end
  end

  def <=>(other)
    self.date <=> other.date
  end

  def coordinate(criteria); @ripeness.coordinate(criteria) end

  def keep?; @ripeness.coordinates.keep? end

  def prune?; !self.keep? end

  def erase!
    if self.directory?
      `rm -rf "#{@path}"`
    else
      File.delete(@path)
    end
    rescue
      Log.error("unable to delete file #{@path}")
  end

end
