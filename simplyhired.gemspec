# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simplyhired/version'

Gem::Specification.new do |spec|
  spec.name          = "simplyhired"
  spec.version       = Simplyhired::VERSION
  spec.authors       = ["murty korada"]
  spec.email         = [""]
  spec.summary       = %q{Wrapper for Simplyhired xml api.}
  spec.description   = %q{Wrapper for Simplyhired xml api.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "minitest", "~> 4.7.5"

  spec.add_dependency "ox", "~> 2.0"

end
