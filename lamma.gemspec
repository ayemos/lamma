# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lamma/version'

Gem::Specification.new do |spec|
  spec.name          = "lamma"
  spec.version       = Lamma::VERSION
  spec.authors       = ["Yuichiro Someya"]
  spec.email         = ["ayemos.y@gmail.com"]

  spec.summary       = %q{Deploy toolset for Amazon Lambda functions.}
  spec.description   = %q{Deploy toolset for Amazon Lambda functions..}
  spec.homepage      = "https://github.com/ayemos/Lamma"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata["yard.run"] = "yri" # use "yard" to build full HTML docs.

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "yard", "~> 0.9"

  spec.add_dependency "aws-sdk", "~> 2"
  spec.add_dependency "thor", "~> 0.19"
  spec.add_dependency "rubyzip", "~> 1.2"
  spec.add_dependency "inifile", "~> 3.0"
end
