#!/usr/bin/env ruby

require 'yaml'

$proj_dir = File.dirname(__FILE__)

$jobs = YAML.load_file($proj_dir+'/jobs.yaml').map do |name, settings|
  Job.new(name, settings) 
end

p $jobs 



