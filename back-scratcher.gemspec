# -*- encoding: utf-8 -*-
require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Sean Madsen"]
  gem.email         = ["sean@bikesnotbombs.org"]
  gem.description   = %q{A tool to make and manage backups for multiple data sources}
  gem.summary       = %q{A tool to make and manage backups}
  gem.homepage      = "https://github.com/seanmadsen/back-scratcher"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.add_dependency('gli', '~> 2.4.0')

  gem.name          = "back-scratcher"
  gem.require_paths = ["lib"]
  gem.version       = VERSION
end
