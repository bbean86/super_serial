# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'super_serial/version'

Gem::Specification.new do |spec|
  spec.name          = "super_serial"
  spec.version       = SuperSerial::VERSION
  spec.authors       = ["Ben Bean"]
  spec.email         = ["bbean86@gmail.com"]
  spec.description   = 'Robust Rails serialization'
  spec.summary       = "This gem adds some underlying structure and features |
                        to Rails' serialize method. It adds the ability to   |
                        store default values with robust type checking and   |
                        ActiveRecord-style automatic conversions, and        |
                        defines accessor methods for any entries given."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "activesupport", "~> 3.2"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'temping'
end
