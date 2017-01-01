require "./stats/leader"
require "./stats/self_info"

module Etcd
  class StatsApi

    getter key_endpoint : String

    def initialize(@client : Client)
      @key_endpoint = "#{client.version_prefix}/stats"
    end

    def leader : Stats::Leader
      path = key_endpoint + "/leader"
      res = @client.get(path)
      Stats::Leader.from_json(res.body)
    end

    def self_info : Stats::SelfInfo
      path = key_endpoint + "/self"
      res = @client.get(path)
      Stats::SelfInfo.from_json(res.body)
    end
  end
end
