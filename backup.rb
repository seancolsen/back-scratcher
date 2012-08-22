#!/usr/bin/env ruby

$proj_dir = File.dirname(__FILE__)
$:.unshift($proj_dir) 

require 'yaml'
require 'lib/job_collection'

jobs_file = File.join($proj_dir, 'jobs.yaml')
jobs = JobCollection.load_from_yaml(jobs_file)

case ARGV[0]
  when 'backup'; jobs.backup
  when 'prune';  jobs.prune
  when 'report'; jobs.report
  else; raise 'Invalid command. Must be "backup", "prune", or "report".'
end

