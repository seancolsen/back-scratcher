#!/usr/bin/env ruby

require 'yaml'

$proj_dir = File.dirname(__FILE__)


class Duration
  attr_accessor :seconds
  UNITS = { :second => 1, 
            :minute => 60,
            :hour   => 60*60, 
            :day    => 60*60*24, 
            :year   => 60*60*24*365 }
  def initialize(description)
    if description.eql?('eternity') 
      @seconds = 0
    else
      value, units = description.to_s.split
      multiplier = units.nil? ? 1 : UNITS[units.downcase.chomp('s').to_sym]
      if multiplier.nil? then raise "Unknown duration units '#{units}'" end    
      @seconds = value.to_i * multiplier
    end
  end
end 

class Interval
  attr_accessor :period, :lifetime 
  def initialize(phrase)
    period, lifetime = phrase.split(' for ') 
    @period = Duration.new(period)
    @lifetime = Duration.new(lifetime)
  end
end

class Policy
  attr_accessor :intervals
  def initialize(intervals)
    # expects an array of interval phrases 
    @intervals = intervals.map {|i| Interval.new(i)} 
  end
end

class Job
  attr_accessor :name, :host
  def initialize(name, settings)
    @name = name
    @policy = Policy.new(settings['keep-every']) 
    @source = settings['source'] 
    @type = @source['database'] ? :database : :filesystem
  end
end

$jobs = YAML.load_file($proj_dir+'/jobs.yaml').map do |name, settings|
  Job.new(name, settings) 
end

p $jobs 



