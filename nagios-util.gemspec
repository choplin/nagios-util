# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nagios/util/version'

Gem::Specification.new do |spec|
  spec.name          = "nagios-util"
  spec.version       = Nagios::Util::VERSION
  spec.authors       = ["choplin"]
  spec.email         = ["choplin.choplin@gmail.com"]
  spec.description   = %q{command line tools for nagios}
  spec.summary       = %q{command line tools for nagios}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "term-ansicolor"
  spec.add_runtime_dependency "terminal-table"
  spec.add_runtime_dependency "erubis"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
