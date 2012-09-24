require 'lib/record'
require 'lib/duration'

class Vault
  attr_accessor :directory, :records
  include Enumerable

  def initialize(path, policy)
    @directory = path
    @records = Record.from_dir_contents(@directory)
    @policy = policy
    @job_name = File.basename(@directory)
  end

  def non_zero_record_count; non_zero_records.length end

  def ensure_exists
    unless File.exists?(@directory) 
      `mkdir -p #{@directory}` 
    end
  end

  def empty?; self.non_zero_record_count == 0 end

  def each(&block); @records.each(&block) end

  def add_record(path)
    if File.exists?(path)
      @records << Record.new(path) 
    else
      Log.warn("new record doesn't exist at #{path}")
    end
  end
  
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

  def prune(opts)
    Log.info "pruning #{@job_name}"
    self.check_ripeness
    @records.sort_by(&:path).each do |record|
      descriptor = "#{@job_name}/#{record.file}"
      if opts[:pretend] 
        if record.prune? 
          Log.info    "TO PRUNE: #{descriptor} " 
        else 
          Log.verbose "    keep: #{descriptor} " 
        end
      else # no-pretend
        if record.prune? 
          if record.erase!
            Log.info  "PRUNED: #{descriptor} " 
          else
            Log.error "Unable to prune #{descriptor}"
          end
        else 
          Log.verbose "  kept: #{descriptor} " 
        end
      end
    end
  end

end
