require 'lib/record'
require 'lib/duration'

class Vault
  attr_accessor :name, :directory, :records
  include Enumerable

  def initialize(job_name)
    @name = job_name
    @directory = File.join($proj_dir,'vault',@name)
    @records = Record.from_dir_contents(@directory)
  end

  def record_count; @records.length end

  def ensure_exists
    unless File.exists?(@directory) 
      `mkdir -p #{@directory}` 
    end
  end

  def empty?; self.record_count == 0 end

  def each(&block); @records.each(&block) end

  def add_record(filename); @records << Record.new(filename) end
  
  def last_modified 
    self.empty? ? nil : @records.max.date 
  end

end
