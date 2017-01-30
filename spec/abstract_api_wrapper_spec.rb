require 'helper'

TEST_OPTIONS = {
  base_url: 'https://mysuperapi.com/api',
  apiver: 'v3',
  access_token: 'mysupersecrettoken'
}

describe 'AbstractApiWrapper' do
  describe 'Client' do
    it 'should create a Client with the given options' do
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

    it 'should return a Request instance' do
      request = @client.users.all
      expect(request.client).to be_kind_of(AbstractApiWrapper::Request)
    end

    it 'should return the same Request instance' do
      user = @client.users.find(1)
      project = user.projects.find(1)

      expect(user).to be_kind_of(AbstractApiWrapper::Request)
      expect(project).to be_kind_of(AbstractApiWrapper::Request)

      expect(user.object_id).to eq(project.object_id)
    end

    it 'should set a Collection instance for an array response' do
      stub_request(:get, "#{TEST_OPTIONS[:base_url]}/users?apiver=v3")
        .to_return(status: 200, body: '[]')

      users = @client.users.all.run
      expect(users).to be_kind_of(AbstractApiWrapper::Response::Collection)
    end

    it 'should set a Resource instance for an object response' do
      stub_request(:get, "#{TEST_OPTIONS[:base_url]}/users/1?apiver=v3")
        .to_return(status: 200, body: '{}')

      user = @client.users.find(1).run
      expect(user).to be_kind_of(AbstractApiWrapper::Response::Resource)
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

    it 'should set the path chain to get a collection' do
      request = @client.users.find(1).projects.all(active: true)
      expect(request.chain).to eq(['users', 'find', 'projects', 'all'])
      expect(request.path).to eq(['users', '1', 'projects'])
      expect(request.filters).to eq({'active' => true})
    end

    it 'should set the path chain to make a head request' do
      request = @client.users.find(1).projects.all(active: true).head
      expect(request.chain).to eq(['users', 'find', 'projects', 'all', 'head'])
      expect(request.path).to eq(['users', '1', 'projects'])
      expect(request.filters).to eq({'active' => true})
    end

    it 'should set the path to create resource' do
      request = @client.users.create(name: 'Jon Snow')
      expect(request.chain).to eq(['users', 'create'])
      expect(request.path).to eq(['users'])
      expect(request.params).to eq({ 'name' => 'Jon Snow' })
    end

    it 'should set the path to update a resource' do
      request = @client.users.find(1).update(name: 'Jon Targaryen')
      expect(request.chain).to eq(['users', 'find', 'update'])
      expect(request.path).to eq(['users', '1'])
      expect(request.params).to eq({ 'name' => 'Jon Targaryen' })
    end

    it 'should set the path to delete a resoure' do
      request = @client.users.find(1).destroy
      expect(request.chain).to eq(['users', 'find', 'destroy'])
      expect(request.path).to eq(['users', '1'])
      expect(request.params).to eq({})
    end

    it 'should raise an error if no resoure to destroy is given' do
      expect {
        request = @client.users.destroy
      }.to raise_error(AbstractApiWrapper::Request::NoResourceGiven)
    end
  end

  describe 'Response' do
    before(:each) do
      @client = AbstractApiWrapper::Client.new(TEST_OPTIONS)

      stub_request(:get, TEST_OPTIONS[:base_url])
        .to_return(status: 200, body: '[]')

      @request = Faraday.get(TEST_OPTIONS[:base_url])
    end

    it 'should return a Response instance' do
      response = AbstractApiWrapper::Response.new(@request)
      expect(response).to be_kind_of(AbstractApiWrapper::Response)
    end

    it 'should parse the response body as JSON' do
      response = AbstractApiWrapper::Response.new(@request)
      expect(response.body).to be_kind_of(AbstractApiWrapper::Response::Collection)
    end

    it 'should return success? and stauts code' do
      response = AbstractApiWrapper::Response.new(@request)
      expect(response.success?).to be(true).or be(false)
      expect(response.status).to be_kind_of(Integer)
    end

    describe 'Resource' do
      before(:each) do
        @item = { id: 1, full_name: 'Jon Snow', email: 'jon@winterfell.com' }
      end

      it 'should create a new Resource from a Hash' do
        resource = AbstractApiWrapper::Response::Resource.new(@item)

        expect(resource).to be_kind_of(Hashie::Mash)
        expect(resource.id).to eq(1)
        expect(resource.full_name).to eq('Jon Snow')
        expect(resource.email).to eq('jon@winterfell.com')
        expect(resource.request).to be_nil
      end

      it 'should assign the Request object from params' do
        request = Faraday.get(TEST_OPTIONS[:base_url])
        resource = AbstractApiWrapper::Response::Resource.new(@item, request)

        expect(resource).to be_kind_of(Hashie::Mash)
        expect(resource.request).to be_kind_of(Faraday::Response)
      end
    end

    describe 'Collection' do
      before(:each) do
        @items = [
          { id: 1, full_name: 'Jon Snow', email: 'jon@winterfell.com' },
          { id: 1, full_name: 'Jon Snow', email: 'tyrion@lannisport.com' },
        ]
      end

      it 'should create a new Collection instance' do
        request = Faraday.get(TEST_OPTIONS[:base_url])
        collection = AbstractApiWrapper::Response::Collection.new(@items, request)

        expect(collection).to be_kind_of(Array)
        expect(collection.size).to be(2)
        expect(collection.headers).to be_kind_of(Hashie::Mash)
        expect(collection.pagination).to be_kind_of(Hashie::Mash)
      end
    end
  end

end