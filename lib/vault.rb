require 'lib/record'
require 'lib/duration'

class Vault
  attr_accessor :directory, :records
  include Enumerable

  def initialize(path)
    @directory = path
    @records = Record.from_dir_contents(@directory)
  end

  def non_zero_record_count; non_zero_record.length end

  def ensure_exists
    unless File.exists?(@directory) 
      `mkdir -p #{@directory}` 
    end
  end

  def empty?; self.non_zero_record_count == 0 end

  def each(&block); @records.each(&block) end

  def add_record(path); @records << Record.new(path) end
  
  def non_zero_records; @records.select {|r| r.substantial?} end
  
  def last_modified; self.empty? ? nil : self.non_zero_records.max.date end

  def latest_record; self.empty? ? nil : self.non_zero_records.max end

end
