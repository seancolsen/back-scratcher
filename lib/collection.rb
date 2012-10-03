class Collection
  attr_accessor :jobs, :path
  include Enumerable

  def initialize(args)
    @path = args.shift || '.'
    self.populate_jobs_from_yaml_file(File.join(@path,'jobs.yaml'))
    self.filter_jobs!(args)
    self.ensure_unique_jobs
    Log.fatal("no valid jobs specified") if @jobs.empty?
  end

  def populate_jobs_from_yaml_file(file)
    Log.fatal(<<-MSG.flatten) if !File.exists?(file)
      Jobs configuration file not found at #{file}
      MSG
    @jobs = YAML.load_file(file).map do |name, settings|
      Job.new(name, settings, path ) 
    end
  end

  def filter_jobs!(job_names)
    if !job_names.empty?
      job_names.each do |name| 
        Log.warn(<<-MSG.flatten) if !@jobs.map(&:name).include?(name)
          invalid job "#{name}" specified
          MSG
      end
      @jobs.delete_if {|j| !job_names.include?(j.name) }
    end
  end

  def ensure_unique_jobs
    grouped_jobs = @jobs.group_by(&:name)
    duplicate_names = Hash[grouped_jobs.select{|k,v| v.length > 1}].keys
    if !duplicate_names.empty?
      duplicate_names.each do |name|
        Log.warn(<<-MSG.flatten)
          Duplicate jobs specified with the name "#{name}". 
          Only the first specification will be used
          MSG
      end
      @jobs = grouped_jobs.map {|k,v| v.first}
    end
  end

  def each(&block); @jobs.each(&block) end

  def backup
    @jobs.each {|job| job.backup }
  end

  def try_backup
    @jobs.each {|job| job.try_backup }
  end

  def prune(opts)
    @jobs.each {|job| job.prune(opts) }
  end

  def report(opts)
    date = Time.now.strftime('%FT%R')
    path = File.expand_path(@path)
    size = if opts[:quick]
      "(unknown due to quick reporting)"
      else Size.of_directory(@path).approx_human_description  
     end 
    puts <<-MSG.unindent
      == Back Scratcher Report == 
      date: #{date}
      collection_path: #{path}
      collection_size: #{size}
      MSG
    @jobs.sort_by(&:name).each {|job| job.report(opts) }
  end

end

