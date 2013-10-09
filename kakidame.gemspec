# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kakidame/version'

Gem::Specification.new do |spec|
  spec.name          = "kakidame"
  spec.version       = Kakidame::VERSION
  spec.authors       = ["dtan4"]
  spec.email         = ["dtanshi45@gmail.com"]
  spec.description   = %q{Web Client for Viewing Markdown and Source Code}
  spec.summary       = %q{Markdown Preview Server}
  spec.homepage      = "https://github.com/dtan4/kakidame"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra"
  spec.add_dependency "redcarpet"
  spec.add_dependency "slim"
  spec.add_dependency "dalli"
  spec.add_dependency "thin"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "sinatra-reloader"
  spec.add_development_dependency "pry"
end
