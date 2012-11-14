class Report
  attr_reader :collection, :opts

  def initialize(collection, opts)
    @collection = collection
    @opts = opts
  end

  def print
    date = Time.now.strftime('%FT%R')
    path = File.expand_path(@collection.path)

    size = if opts[:quick]
             "(unknown due to quick reporting)"
           else
             Size.of_directory(@collection.path).approx_human_description
           end

    puts <<-MSG.unindent
      == Back Scratcher Report ==
      date: #{date}
      collection_path: #{path}
      collection_size: #{size}
    MSG

    @collection.jobs.sort_by(&:name).each do |job|
      job.report(opts)
    end
  end
end
