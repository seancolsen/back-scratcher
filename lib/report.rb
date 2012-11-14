class Report
  attr_reader :collection, :opts

  def initialize(collection, opts)
    @collection = collection
    @opts = opts
    analyze_collection
  end

  def analyze_collection
    unless opts[:quick]
      @size = Size.of_directory(@collection.path)

      if opts[:'disk-usage']
        @disk_usage = Utility.disk_usage(@collection.path)
      end
    end
  end

  def print
    puts header
    puts additional_info

    @collection.jobs.sort_by(&:name).each do |job|
      job.report(opts)
    end
  end

  def header
    date = Time.now.strftime('%FT%R')

    <<-MSG.unindent
      == Back Scratcher Report ==
      date: #{date}
    MSG
  end

  def additional_info
    msg = ""
    if @disk_usage
      msg += <<-MSG.unindent
      disk_space_used: #{@disk_usage[:used].approx_human_description} (#{@disk_usage[:percent_used]})
      disk_space_available: #{@disk_usage[:available].approx_human_description}
      MSG
    end
    path = File.expand_path(@collection.path)
    size = if opts[:quick]
             "(unknown due to quick reporting)"
           else
             @size.approx_human_description
           end

    msg += <<-MSG.unindent
      collection_path: #{path}
      collection_size: #{size}
    MSG
  end
end
