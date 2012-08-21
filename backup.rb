#!/usr/bin/env ruby

$proj_dir = File.dirname(__FILE__)
$:.unshift($proj_dir) 

require 'yaml'
require 'lib/job_collection'

jobs = JobCollection.load_from_yaml($proj_dir+'/jobs.yaml')

case ARGV[0]
  when 'backup'; jobs.backup
  when 'prune';  jobs.prune
  when 'report'; jobs.report
  else; raise 'Invalid command. Must be "backup", "prune", or "report".'
end

