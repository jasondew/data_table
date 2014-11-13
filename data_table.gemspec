# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "data_table/version"

Gem::Specification.new do |spec|
  spec.name          = "data_table"
  spec.version       = DataTable::VERSION
  spec.authors       = ["Jason Dew"]
  spec.email         = ["jason.dew@gmail.com"]
  spec.summary       = %q{Simple data preparation from ActiveRecord/Mongoid to the jQuery DataTables plugin}
  spec.description   = %q{Simple data preparation from ActiveRecord/Mongoid to the jQuery DataTables plugin}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
