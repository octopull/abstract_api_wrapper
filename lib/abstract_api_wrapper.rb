require 'abstract_api_wrapper/version'
require 'json'
require 'faraday'
require 'hashie/mash'

class AbstractApiWrapper
  class Client
    attr_reader :access_token, :base_url, :apiver

    def initialize(**options)
      @base_url      = options[:base_url]
      @apiver        = options[:apiver]
      @access_token  = options[:access_token]
    end

    def method_missing(name, *params, &block)
      Request.new(name.to_s, self)
    end
  end

  class Request
    attr_accessor :path, :filters, :chain

    METHODS_MAP = {
      'all'     => 'get',
      'head'    => 'head',
      'find'    => 'get',
      'create'  => 'post',
      'update'  => 'put',
      'destroy' => 'delete'
    }.freeze

    def initialize(*options)
      @client  = options[1]
      @path    = []
      @chain   = []
      @filters = Hashie::Mash.new
      @params  = Hashie::Mash.new

      method_name = options[0]

      unless method_name.nil?
        @path  << method_name
        @chain << method_name
      end
    end

    def method_missing(name, *params, &block)
      method_name = name.to_s
      return self if chain.last == method_name

      chain.push(method_name)

      case method_name
      when 'all'
        filters.merge!(params.first || {})
      when 'head'
        filters.merge!(params.first || {})
      when 'find'
        path.push(params.first.to_s)
      when 'create'
        @params = Hashie::Mash.new(params.first || {})
      when 'update'
        if chain[-2] == 'find'
          @params = Hashie::Mash.new(params.first || {})
        end
      when 'destroy'
        if chain[-2] == 'find'
          path.push(params.first.to_s)
        end
      else
        path.push(method_name)
      end

      self
    end

    def run
      method = METHODS_MAP[@chain.last] || 'get'
      params = @params.any? ? @params.to_json : nil

      request = Faraday.send(method, endpoint, params, headers)
      response = Response.new(request)

      # Reset variables
      path    = []
      chain   = []
      filters = Hashie::Mash.new
      params  = Hashie::Mash.new

      response.body
    end

    def headers
      {
        'Authorization' => "token #{@client.access_token}",
        'Content-Type' => 'application/json'
      }
    end

    def endpoint
      # Here is a Query String API versioning with the `apiver` param
      # You can change this to whatever your API versioning system is
      filters.apiver = @client.apiver
      query_string   = filters.map { |k, v| "#{k}=#{v}" }.join('&')

      "#{@client.base_url}/#{path.join('/')}?#{query_string}"
    end
  end

  class Response

    def initialize(request)
      @request = request

      @parsed_body = if (request.body.nil? || request.body.empty?)
        []
      else
        JSON.parse(request.body)
      end
    end

    def body
      if @parsed_body.is_a?(Hash)
        Response::Resource.new(@parsed_body, @request)
      elsif @parsed_body.is_a?(Array)
        collection = @parsed_body.map do |item|
          Response::Resource.new(item)
        end

        Response::Collection.new(collection, @request)
      end
    end

    class Resource < Hashie::Mash
      attr_reader :request

      def initialize(*options)
        @request = options[1] if options[1]
        super(options[0])
      end
    end

    class Collection < Array
      attr_reader :request

      def initialize(*options)
        @request = options[1] if options[1]
        super(options[0])
      end

      def headers
        @headers ||= @request.headers
      end

      def pagination
        @pagination ||= Hashie::Mash.new(
          next_page: headers['x-next-page'].to_i,
          offset: headers['x-offset'].to_i,
          page: headers['x-page'].to_i,
          per_page: headers['x-per-page'].to_i,
          prev_page: headers['prev_page'].to_i,
          total: headers['x-total'].to_i,
          total_pages: headers['x-total-pages'].to_i
        )
      end
    end
  end
end