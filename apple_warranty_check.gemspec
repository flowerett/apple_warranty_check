# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apple_warranty_check/version'

Gem::Specification.new do |spec|
  spec.name          = "apple_warranty_check"
  spec.version       = AppleWarrantyCheck::VERSION
  spec.authors       = ["Nick Chernyshev"]
  spec.email         = ["nick.chernyshev@gmail.com"]

  spec.summary       = 'Check Apple warranty by IMEI'
  spec.description   = 'Tool to parse warranty info for Apple devices from official site.'
  spec.homepage      = "https://github.com/flowerett/apple_warranty_check"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
