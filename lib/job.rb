class Job
  attr_accessor :name, :host, :user, :policy, :source, :type, :vault,
                :collection_path, :constraints

  # Number of seconds before a backup is scheduled that it's okay for us 
  # make one.
  SLACK = 120 

  def initialize(name, settings, collection_path)
    @name = name
    @collection_path = collection_path
    @policy = Policy.new(settings['keep-every']) 
    @constraints = Constraints.new(settings['only-backup-when'])
    @source = settings['source'] 
    @type = @source['database'] ? :database : :filesystem
    @vault = Vault.new(File.join(@collection_path,'vault',@name), @policy) 
    @user = settings['user']
    @host = settings['host']
  end

  def reason_to_skip
    if !@constraints.timing_ok?
      'constraints say now is not a good time'
    elsif @vault.last_modified == nil
      nil
    elsif Time.now - @vault.last_modified <= 
        @policy.running_period.seconds - SLACK
      "we have a recent backup from #{@vault.last_modified}"
    else nil
    end
  end

  def needs_backup?
    self.reason_to_skip == nil
  end

  def backup
    Log.info("backing up #{@name} ")
    @vault.ensure_exists 
    dest_file = self.new_record_path
    if @type == :database 
      self.backup_database(dest_file)
    else
      self.backup_filesystem(dest_file)
    end
    @vault.add_record(dest_file)
  end

  def new_record_path
    ext = @type == :database ? '.sql.gz' : ''
    File.join(@vault.directory, Time.now.strftime('%Y-%m-%dT%H-%M-%S_0'+ext) )
  end

  def backup_database(dest_file)
    dump = <<-CMD.flatten
      mysqldump 
      --skip-dump-date
      -u#{@source['user']} 
      -p#{@source['password']}
        #{@source['database']}
      CMD
    `ssh #{@user}@#{@host} '#{dump} | gzip -c' > "#{dest_file}" `
  end 

  def backup_filesystem(dest_file)
    ignore = @source['ignore'].map{|i| "--exclude='#{i}' "}.reduce(:+)
    link_dest = if @vault.latest_record
      "--link-dest='#{File.expand_path(@vault.latest_record.path)}' "
      else ''
      end
    source_directory = @source['directory'].chomp('/').concat('/')
    cmd = <<-CMD.flatten
      rsync -avzx --super #{ignore} #{link_dest} 
      "#{@user}@#{@host}:'#{source_directory}'"
      "#{dest_file}"
      CMD
    puts cmd
    Log.verbose(`#{cmd}`)
  end 

  def try_backup
    if self.needs_backup? 
      self.backup 
    else
      Log.verbose("Skipping #{@name} because #{self.reason_to_skip}")
    end 
  end

  def prune(opts); @vault.prune(opts) end

  def report(opts)
    metrics = [
      [:date_of_last_backup       , :skip_when_empty , :fast ] ,
      [:time_since_last_backup    , :skip_when_empty , :fast ] ,
      [:backup_frequency          , :always          , :fast ] ,
      [:backup_scheduling         , :always          , :fast ] ,
      [:size_of_last_backup       , :skip_when_empty , :fast ] ,
      [:size_of_largest_backup    , :skip_when_empty , :fast ] ,
      [:size_of_average_backup    , :skip_when_empty , :fast ] ,
      [:size_of_median_backup     , :skip_when_empty , :fast ] ,
      [:size_of_entire_vault      , :skip_when_empty , :slow ] ,
      [:number_of_backups_now     , :always          , :fast ] ,
      [:number_of_backups_allowed , :always          , :fast ]
    ]
    puts "\n-- job #{@name} --"
    metrics.each do |i|
      metric, cond, speed = i
      if (!@vault.empty? || cond==:always) and (!opts[:quick] || speed==:fast)
        print metric.to_s + ": "
        puts self.send( ("report_" + metric.to_s).to_sym )
      end
    end
  end

  def report_date_of_last_backup
    @vault.last_modified.strftime('%FT%R')
  end

  def report_time_since_last_backup
    duration = Duration.new(Time.now - @vault.last_modified)
    "about #{duration.approx_human_description} ago"
  end

  def report_backup_frequency
    "roughly every #{@vault.policy.running_period.approx_human_description}"
  end

  def report_backup_scheduling
    @constraints.human_description || 'all the time'
  end 

  def report_size_of_last_backup
    @vault.latest_record.size.approx_human_description
  end

  def report_size_of_largest_backup
    @vault.sort_by(&:size).last.size.approx_human_description
  end

  def report_size_of_average_backup
    sizes = @vault.map(&:size)
    (sizes.inject(:+)/sizes.length).approx_human_description
  end

  def report_size_of_median_backup
    sorted = @vault.map(&:size).sort
    len = sorted.length
    size = len%2 == 1 ? sorted[len/2] : (sorted[len/2-1]+sorted[len/2])/2.to_f
    size.approx_human_description
  end

  def report_size_of_entire_vault
    Size.of_directory(@vault.directory).approx_human_description
  end

  def report_number_of_backups_now
    @vault.non_zero_record_count
  end

  def report_number_of_backups_allowed
    @policy.record_capacity
  end

end

