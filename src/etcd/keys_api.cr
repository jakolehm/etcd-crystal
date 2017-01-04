require "./keys/response"

module Etcd

  class KeysApi

    getter key_endpoint : String

    struct SetOptions
      @prev_exist : Bool | Nil
      @prev_value : String | Nil
      @prev_index : Int64 | Nil
      @ttl : Int64 | Nil
      @refresh: Bool | Nil

      property prev_exist, prev_value, prev_index, ttl, refresh

      def initialize(@prev_exist = nil, @prev_value = nil, @prev_index = nil, @ttl = nil, @refresh = false)
      end

      def to_hash
        json = {} of String => (String | Nil | Int64 | Bool)
        json["prevExist"] = self.prev_exist unless self.prev_exist.nil?
        json["prevValue"] = self.prev_value unless self.prev_value.nil?
        json["prevIndex"] = self.prev_index unless self.prev_index.nil?
        json["ttl"] = self.ttl unless self.ttl.nil?
        json["refresh"] = self.refresh unless self.refresh.nil?

        json
      end
    end

    struct GetOptions
      @recursive : Bool | Nil
      @sort : Bool | Nil
      @quorum : Bool | Nil

      property recursive, sort, quorum

      def initialize(@recursive = nil, @sort = nil, @quorum = nil)
      end

      def to_hash
        json = {} of String => String
        json["recursive"] = self.recursive.to_s unless self.recursive.nil?
        json["sort"] = self.sort.to_s unless self.sort.nil?
        json["quorum"] = self.quorum.to_s unless self.quorum.nil?
        json
      end
    end

    def initialize(@client : Client)
      @key_endpoint = "#{client.version_prefix}/keys"
    end

    def get(key : String, opts = GetOptions.new ) : Keys::Response
      path = key_endpoint + key
      res = @client.get(path, opts.to_hash)
      Keys::Response.from_http_response(res)
    end

    def set(key : String, value : String, opts = SetOptions.new) : Keys::Response
      path = key_endpoint + key
      body = opts.to_hash
      body["value"] = value
      res = @client.put(path, body)
      Keys::Response.from_http_response(res)
    end

    def create_in_order(key : String, value : String, opts = SetOptions.new) : Keys::Response
      path = key_endpoint + key
      body = opts.to_hash
      body["value"] = value
      res = @client.post(path, body.to_json)
      Keys::Response.from_http_response(res)
    end

    def exists?(key : String) : Bool
      begin
        Etcd::Log.debug("Checking if key:' #{key}' exists")
        get(key)
        true
      rescue e : Etcd::Error
        Etcd::Log.debug("Key does not exist #{key}")
        false
      end
    end

    def create(key : String, value : String, opts = SetOptions.new) : Keys::Response
      opts.prev_exist = false
      set(key, value, opts)
    end

    def update(key : String, value : String, opts = SetOptions.new) : Keys::Response
      opts.prev_exist = true
      set(key, value, opts)
    end

    def delete(key : String) : Keys::Response
      path = key_endpoint + key
      res = @client.delete(path)
      Keys::Response.from_http_response(res)
    end

    def mkdir(key : String, opts = SetOptions.new) : Keys::Response
      path = key_endpoint + key
      body = opts.to_hash
      body["dir"] = true
      res = @client.put(path, body.to_json)
      Keys::Response.from_http_response(res)
    end

    def rmdir(key : String, recursive = false) : Keys::Response
      path = key_endpoint + key
      params = {"dir" => true, "recursive" => recursive}
      res = @client.delete(path, params)
      Keys::Response.from_http_response(res)
    end
  end
end
