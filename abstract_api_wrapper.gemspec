# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'abstract_api_wrapper/version'

Gem::Specification.new do |spec|
  spec.name          = 'abstract_api_wrapper'
  spec.version       = AbstractApiWrapper::VERSION
  spec.authors       = ['Juan Puelpan']
  spec.email         = ['juan@octopull.us']

  spec.summary       = %q{An abstract REST API wrapper}
  spec.description   = %q{An abstract REST API wrapper based on missing_method magic}
  spec.homepage      = "https://github.com/octopull/abstract_api_wrapper"

  spec.files         = `git ls-files`.split("\n")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'json'    , '~> 2.0'
  spec.add_dependency 'faraday' , '~> 0.10'
  spec.add_dependency 'hashie'  , '~> 3.4'

  spec.add_development_dependency 'bundler' , '~> 1.11'
  spec.add_development_dependency 'rake'    , '~> 10.0'
  spec.add_development_dependency 'rspec'   , '~> 3.5'
  spec.add_development_dependency 'webmock' , '~> 1.24'
end
