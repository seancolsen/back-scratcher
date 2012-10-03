class Time
  def self.new_with_time_only(time_string)
    hour, minute, foo, second = 
      /^(\d{1,2}):(\d\d)(:(\d\d))?$/.match(time_string).captures
    second ||= 0
    now = Time.now
    Time.local(now.year, now.month, now.day, 
               hour.to_i, minute.to_i, second.to_i)
  end

  def time_format
    sec = ':%S' unless self.sec == 0
    self.strftime("%-H:%M#{sec}")
  end

end
