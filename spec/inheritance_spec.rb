require 'helper'

class BasecampApi < AbstractApiWrapper
  class Client < BasecampApi::Client
    def method_missing(name, *params, &block)
      BasecampApi::Request.new(name.to_s, self)
    end
  end

  class Request < BasecampApi::Request
    def headers
      {
        'Authorization' => "Bearer #{@client.access_token}",
        'Content-Type' => 'application/json'
      }
    end

    def endpoint
      query_string = filters.map { |k, v| "#{k}=#{v}" }.join('&')
      "#{@client.base_url}/#{path.join('/')}.json?#{query_string}"
    end
  end
end

describe 'BasecampApi' do  
  describe 'Request' do
    subject {
      client = BasecampApi::Client.new(
        apiver: '1',
        base_url: 'http://localhost.com',
        access_token: '123'
      )
    }

    it 'should contain a .json in the request endpoint' do
      request = subject.projects.all
      expect(request).to be_kind_of(BasecampApi::Request)
      expect(request.endpoint).to include('projects.json')
    end

    it 'should use Bearer as token in Authorization header' do
      stub_request(:get, 'http://localhost.com/users.json')
        .with(headers: { 'Authorization' => 'Bearer 123' })
        .to_return(status: 200, body: "")

      response = subject.users.all.run
      expect(response.request.status).to be(200)
    end
  end
end