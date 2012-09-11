require 'lib/job'

class Collection
  attr_accessor :jobs, :path
  include Enumerable

  def initialize(path)
    @path = path || '.'
    @jobs = Job.load_from_collection_path(@path)
    # TODO: check for duplicate job names 
  end

  def each(&block); jobs.each(&block) end

  def backup
    jobs.each { |job| job.backup }
  end

  def try_backup
    jobs.each { |job| job.try_backup }
  end

  def prune
    #TODO
    puts 'pruning'
    Log.info('ok here we go')
  end

  def report
    #TODO
    puts 'making report'
  end

end

