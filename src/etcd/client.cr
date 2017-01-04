require "http/client"
require "./errors"
require "./log"
require "./keys_api"
require "./stats_api"

module Etcd
  class Client

    struct Config
      property host, port

      def initialize(@host = "127.0.0.1", @port = 2379)
      end
    end

    getter version_prefix : String = "/v2"

    def initialize(config : Config)
      @client = HTTP::Client.new(config.host, config.port)
      @form_headers = HTTP::Headers{"Content-Type" => "application/x-www-form-urlencoded"}
    end

    def keys : KeysApi
      KeysApi.new(self)
    end

    def stats : StatsApi
      StatsApi.new(self)
    end

    def get(path : String, params = {} of String => String) : HTTP::Client::Response
      uri_path = path
      unless params.empty?
        uri_path += self.map_params(params)
      end
      res = @client.get(uri_path)
      handle_response(res)
    end

    def put(path : String, body : Hash, params = {} of String => String) : HTTP::Client::Response
      uri_path = path
      unless params.empty?
        uri_path += self.map_params(params)
      end
      form_data = self.map_params(body)
      handle_response(@client.put(uri_path, @form_headers, form_data))
    end

    def post(path : String, body : Hash, params = {} of String => String) : HTTP::Client::Response
      uri_path = path
      unless params.empty?
        uri_path += self.map_params(params)
      end
      form_data = self.map_params(body)
      handle_response(@client.post(uri_path, @form_headers, form_data))
    end

    def delete(path : String, params = {} of String => String) : HTTP::Client::Response
      uri_path = path
      unless params.empty?
        uri_path += "?" + self.map_params(params)
      end
      res = @client.delete(uri_path)
      handle_response(res)
    end

    def handle_response(res : HTTP::Client::Response) : HTTP::Client::Response
      if res.success?
        res
      else
        raise Error.from_http_response(res)
      end
    end

    def map_params(params : Hash)
      params.map{ |k, v| "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }.join("&")
    end
  end
end
