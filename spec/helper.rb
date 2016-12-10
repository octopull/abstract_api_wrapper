$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'webmock/rspec'
require 'abstract_api_wrapper'

include WebMock::API
WebMock.enable!