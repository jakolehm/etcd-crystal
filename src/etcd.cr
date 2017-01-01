require "./etcd/client"

module Etcd
  extend self

  VERSION = "0.1.0"

  def client(opts = {} of String => (String | Int64)) : Client
    config = Client::Config.new
    config.host = opts["host"].to_s if opts.has_key?("host")
    config.port = opts["port"].to_i if opts.has_key?("port")
    
    Client.new(config)
  end

  def client(config : Client::Config) : Client
    Client.new(config)
  end
end
