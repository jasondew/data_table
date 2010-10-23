$:.push File.expand_path("../lib", __FILE__)
require "data_table/version"

Gem::Specification.new do |s|
  s.name        = "data_table"
  s.version     = DataTable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jason Dew"]
  s.email       = ["jason.dew@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/data_table"
  s.summary     = %q{Simple data preparation from AR/Mongoid to the jQuery DataTables plugin}
  s.description = %q{Simple data preparation from AR/Mongoid to the jQuery DataTables plugin}

  s.rubyforge_project = "data_table"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "actionpack", "~>3.0.0"
  s.add_dependency "activesupport", "~>3.0.0"
  s.add_dependency "will_paginate", "~>3.0.pre2"

  s.add_development_dependency "rspec", "~>2.0.0"
  s.add_development_dependency "shoulda", "~>2.11.0"
  s.add_development_dependency "rr", "~>1.0.0"
end
