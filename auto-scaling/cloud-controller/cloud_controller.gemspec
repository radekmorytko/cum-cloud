# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloud_controller/version'

Gem::Specification.new do |spec|
  spec.name          = "cloud_controller"
  spec.version       = CloudController::VERSION
  spec.authors       = ["Radoslaw Morytko"]
  spec.email         = ["radoslaw.morytko@gmail.com"]
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]


  spec.add_runtime_dependency "amqp"
  spec.add_runtime_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  # test
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rack-test"
  # this is UTTERLY UGLY
  spec.add_development_dependency "rest-client"
  spec.add_development_dependency "rufus-scheduler"
  spec.add_development_dependency "data_mapper"
  spec.add_development_dependency "dm-sqlite-adapter"
  spec.add_development_dependency "net-ssh"
end
