# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkapi/version'

Gem::Specification.new do |spec|
  spec.name          = "checkapi"
  spec.version       = Checkapi::VERSION
  spec.authors       = ["kaich"]
  spec.email         = ["chengkai1853@163.com"]
  spec.summary       = %q{search private api in frameworks.}
  spec.description   = %q{search private api in frameworks. You need install VAPI in you device to view the api result}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"] + %w{ bin/checkapi}
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib","bin"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
