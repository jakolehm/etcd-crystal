require "./keys/response"

module Etcd

  class KeysApi

    getter key_endpoint : String

    def initialize(@client : Client)
      @key_endpoint = "#{client.version_prefix}/keys"
    end

    def get(key : String, params = {} of String => String) : Keys::Response
      path = key_endpoint + key
      res = @client.get(path, params)
      Keys::Response.from_http_response(res)
    end

    def set(key : String, body : Hash) : Keys::Response
      path = key_endpoint + key
      res = @client.put(path, body.to_json)
      Keys::Response.from_http_response(res)
    end

    def create_in_order(key : String, body : Hash) : Keys::Response
      path = key_endpoint + key
      res = @client.post(path, body.to_json)
      Keys::Response.from_http_response(res)
    end

    def exists?(key : String) : Bool
      Etcd::Log.debug("Checking if key:' #{key}' exists")
      get(key)
      true
    rescue e : KeyNotFound
      Etcd::Log.debug("Key does not exist #{e}")
      false
    end

    def create(key : String, opts = {} of String => String) : Keys::Response
      set(key, opts.merge(prevExist: false))
    end

    def update(key : String, opts = {} of String => String) : Keys::Response
      set(key, opts.merge(prevExist: true))
    end
  end
end
