# -*- encoding: utf-8 -*-
require File.expand_path('../lib/duration/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ["Matt Wilson"]
  s.email         = ["mhw@hypomodern.com"]
  s.description   = %q{Simple utility for parsing durations from strings and comparing them. Basic math is also supported.}
  s.summary       = %q{Parse durations from strings and manipulate them.}
  s.homepage      = "https://github.com/hypomodern/ruby-duration"

  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.name          = "ruby-duration"
  s.require_paths = ["lib"]
  s.version       = Duration::VERSION

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
