class Constraints
  DAYS = ['mon','tue','wed','thu','fri','sat','sun']
  
  def initialize(data)
    @min_time = @max_time = @weekdays = nil
    if data
      @weekdays = DAYS.find_all{|day| data.match(day) }
      times = data.match(/(\d{1,2}:\d\d(:\d\d)?) ?- ?(\d{1,2}:\d\d(:\d\d)?)/)
      if times
        min, foo, max, bar = times.captures
        @min_time = Time.new_with_time_only(min)
        @max_time = Time.new_with_time_only(max)
      end
    end
  end

  def timing_ok?
    self.weekly_timing_ok? and self.daily_timing_ok?
  end

  def weekly_timing_ok?
    today = DAYS[Time.now.wday - 1]
    @weekdays == nil or @weekdays.empty? or @weekdays.include?(today) 
  end

  def daily_timing_ok?
    now = Time.now
    (@min_time == nil or now >= @min_time) and 
    (@max_time == nil or now <= @max_time)
  end

  def human_description
    pieces = []
    pieces << self.day_description if self.day_description
    pieces << self.time_description if self.time_description
    pieces.empty? ? nil : 'only ' + (pieces * ' ')
  end

  def day_description
    if @weekdays and !@weekdays.empty? 
      'on ' + (@weekdays*'/')
    else nil
    end
  end

  def time_description
    if @min_time and @max_time 
      "between #{@min_time.time_format} and #{@max_time.time_format}"
    elsif @min_time
      "after #{@min_time.time_format}"
    elsif @max_time
      "before #{@min_time.time_format}"
    else nil
    end
  end

end
