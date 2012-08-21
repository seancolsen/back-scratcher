require 'lib/job'

class JobCollection
  attr_accessor :jobs
  include Enumerable

  def self.load_from_yaml(file)
    j = self.new
    j.jobs = Job.load_from_yaml(file)
    j
  end

  def each(&block); jobs.each(&block) end

  def backup
    jobs.each { |job| job.try_backup }
  end

  def prune
    #TODO
    puts 'pruning'
  end

  def report
    #TODO
    puts 'making report'
  end

end

