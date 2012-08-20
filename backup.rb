#!/usr/bin/env ruby

$proj_dir = File.dirname(__FILE__)
$:.unshift($proj_dir) 

require 'yaml'
require 'lib/job'

$jobs = Job.load_from_yaml($proj_dir+'/jobs.yaml')

p $jobs[1].vault

