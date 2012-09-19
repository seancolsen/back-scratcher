require 'lib/record'
require 'lib/duration'

class Vault
  attr_accessor :directory, :records
  include Enumerable

  def initialize(path, policy)
    @directory = path
    @records = Record.from_dir_contents(@directory)
    @policy = policy
  end

  def non_zero_record_count; non_zero_records.length end

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

  def check_ripeness
    @records.each { |record| record.create_ripeness(@policy) }
    self.evaluate_record_score
    self.evaluate_coordinate_status
  end

  def evaluate_record_score
    @records.sort! do |x,y| 
      [x.size, x.date, x.file] <=> [y.size, y.date, y.file] 
    end
    @records.each_with_index do |record, index|
      record.ripeness.score = index
    end
  end

  def evaluate_coordinate_status
    @policy.each do |interval|
      @records.select do |record|
        record.coordinate(interval).sheltered?
      end.group_by do |record| 
        record.coordinate(interval).ordinal 
      end.each do |ordinal, records| 
        max_score = records.map {|r| r.ripeness.score}.max
        records.select do |record| 
          record.ripeness.score == max_score 
        end.first.coordinate(interval).keep!
      end
    end
  end

  def prune
    self.check_ripeness
    @records.select do |record|
      record.prune?
    end.each do |record|
      p record.file
    end
  end

end
