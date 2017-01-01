require "./node"

module Etcd
  module Keys
    class Response

      JSON.mapping(
        action: String,
        node: {type: Node},
        prev_node: {type: Node, key: "prevNode", nilable: true}
      )

      forward_missing_to @node
      getter etcd_index : (Int32 | Nil)
      getter raft_index : (Int32 | Nil)
      getter raft_term : (Int32 | Nil)

      def initialize(opts : Hash)
        @action = opts["action"]
        @node = Node.new(opts["node"])
      end

      def indexes_from_headers(headers = {} of String => Int32)
        @etcd_index = headers["etcd_index"]
        @raft_index = headers["raft_index"]
        @raft_term = headers["raft_term"]

        nil
      end

      def self.from_http_response(res : HTTP::Client::Response) : Response
        response = self.from_json(res.body)
        headers = {
          "etcd_index" => res.headers["X-Etcd-Index"].to_i,
          "raft_index" => res.headers["X-Raft-Index"].to_i,
          "raft_term" => res.headers["X-Raft-Term"].to_i
        }
        response.indexes_from_headers(headers)
        response
      end
    end
  end
end
