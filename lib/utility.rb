class Utility
  # uses du -k (size in kilobytes) and multiplies to bytes,
  # rather than du -b (size in bytes) due to cross-platform
  # issues.
  def self.directory_size(dir)
    `du -s -k #{dir}`.split("\t")[0].to_i * 1024
    rescue
      Log.error("unable to determine total directory size of #{dir}")
  end

  def self.disk_usage(mount)
    df_out = `df -k #{mount} | awk 'NR>1 {print $2, $3, $4, $5;}'`.split(/\s+/).map do |n|
      n = n.index("%") ? n : Size.new(n.to_i * 1024)
    end
    Hash[[:total, :used, :available, :percent_used].zip(df_out)]
  end
end
