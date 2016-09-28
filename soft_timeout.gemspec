# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'soft_timeout/version'

Gem::Specification.new do |spec|
  spec.name          = "soft_timeout"
  spec.version       = SoftTimeout::VERSION
  spec.authors       = ["Abhishek Patel"]
  spec.email         = ["abhishek.patel131@gmail.com"]

  spec.summary       = %q{An escape window before Timeout error hits you}
  spec.description   = %q{Provides a better way to handle timeouts in ruby.}
  spec.homepage      = "https://github.com/abhi-patel/soft_timeout"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
