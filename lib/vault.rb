require 'lib/record'

class Vault
  attr_accessor :name, :directory, :records
  include Enumerable

  def initialize(job_name)
    @name = job_name
    @directory = File.join($proj_dir,'vault',@name)
    @records = Record.from_dir_contents(@directory)
  end

  def record_count; @records.length end

  def empty?; self.record_count == 0 end

  def each(&block)
    @records.each(&block) 
  end
  
end
