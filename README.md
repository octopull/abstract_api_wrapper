# AbstractApiWrapper

TODO: summary

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'abstract_api_wrapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install abstract_api_wrapper

## Usage

Modify the `endpoint` method appending the `.json` extension to all requests

```ruby
def endpoint
  query_string = filters.map { |k, v| "#{k}=#{v}" }.join('&')
  "#{@client.base_url}/#{path.join('/')}.json?#{query_string}"
end
```

```ruby
ACCESS_TOKEN = "YOUR ACCESS TOKEN"
client = AbstractApiWrapper::Client.new(access_token: ACCESS_TOKEN, base_url: 'https://launchpad.37signals.com')
authorizations = client.authorization.all.run
# => <AbstractApiWrapper::Response::Resource accounts=#<Hashie::Array [#<AbstractApiWrapper::Response::Resource app_href="https://basecamp.com/xxxxxxx" href="https://basecamp.com/xxxxxxx/api/v1" id=xxxxxxx name="Your Company" product="bcx">, #<AbstractApiWrapper::Response::Resource app_href="https://basecamp.com/xxxxxxx" href="https://basecamp.com/xxxxxxx/api/v1" id=xxxxxxx name="Another company" product="bcx">]> expires_at="2016-12-19T18:13:52.000Z" identity=#<AbstractApiWrapper::Response::Resource email_address="email@yourcompany.com" first_name="Juan" id=xxxxxx last_name="Puelpan">>

account = authorizations.accounts.first
client = AbstractApiWrapper::Client.new(access_token: ACCESS_TOKEN, base_url: account.href)
projects = client.projects.all.run
puts projects
puts projects.pagination
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/octopull/abstract_api_wrapper.

