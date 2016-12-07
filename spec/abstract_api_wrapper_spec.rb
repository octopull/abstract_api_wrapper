$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'abstract_api_wrapper'

describe AbstractApiWrapper do
  TEST_OPTIONS = {
    base_url: 'https://mysuperapi.com/api',
    apiver: 'v3',
    access_token: 'mysupersecrettoken'
  }

  describe 'Client' do
    it 'should create a client with the given options' do
      client = AbstractApiWrapper::Client.new(TEST_OPTIONS)

      expect(client.access_token).to eq('mysupersecrettoken')
      expect(client.base_url).to eq('https://mysuperapi.com/api')
      expect(client.apiver).to eq('v3')
    end
  end

  describe 'Request' do

    before(:each) do
      @client = AbstractApiWrapper::Client.new(TEST_OPTIONS)
    end

    it 'should return a request instance' do
      request = @client.users.all
      expect(request).to be_kind_of(AbstractApiWrapper::Request)
    end

    it 'should create a path as array' do
      request = @client.users.find(1)
      expect(request.path).to be_kind_of(Array)
      expect(request.path.last).to eq('1')
      expect(request.path).to eq(['users', '1'])
    end

    it 'should set the filters' do
      request = @client.users.all(active: true)
      expect(request.filters).to be_kind_of(Hashie::Mash)
      expect(request.filters).to eq({ 'active' => true })
    end
  end

end