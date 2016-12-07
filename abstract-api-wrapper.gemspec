# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'abstract-api-wrapper/version'

Gem::Specification.new do |spec|
  spec.name          = 'abstract-api-wrapper'
  spec.version       = AbstractApiWrapper::VERSION
  spec.authors       = ['Juan Puelpan']
  spec.email         = ['juan@octopull.us']

  spec.summary       = %q{An abstract REST API wrapper}
  spec.description   = %q{An abstract REST API wrapper}
  spec.homepage      = "https://github.com/octopull/abstract_api_wrapper"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files`.split("\n")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'json'    , '~> 2.0.2'
  spec.add_dependency 'faraday' , '~> 0.10.0'
  spec.add_dependency 'hashie'  , '~> 3.4.6'

  spec.add_development_dependency 'bundler' , '~> 1.11'
  spec.add_development_dependency 'rake'    , '~> 10.0'
  spec.add_development_dependency 'rspec'   , '~> 3.5.0'
end
