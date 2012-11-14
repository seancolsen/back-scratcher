class Utility
  # uses du -k (size in kilobytes) and multiplies to bytes,
  # rather than du -b (size in bytes) due to cross-platform
  # issues.
  def self.directory_size(dir)
    `du -s -k #{dir}`.split("\t")[0].to_i * 1024
    rescue
      Log.error("unable to determine total directory size of #{dir}")
  end
end
