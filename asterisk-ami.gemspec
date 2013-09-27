# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asterisk/ami/version'

Gem::Specification.new do |spec|
  spec.name          = "asterisk-ami"
  spec.version       = Asterisk::Ami::VERSION
  spec.authors       = ["Stewart McKee"]
  spec.email         = ["stewart@theizone.co.uk"]
  spec.description   = %q{Asterisk AMI integration gem}
  spec.summary       = %q{Asterisk AMI integration gem}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "lib/asterisk"]

  spec.add_dependency "titleize"
  spec.add_dependency "json"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
