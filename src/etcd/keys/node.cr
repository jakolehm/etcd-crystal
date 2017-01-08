module Etcd
  module Keys
    class Node
      include Comparable(Node)

      JSON.mapping(
        created_index: {type: Int32, key: "createdIndex", nilable: true},
        modified_index: {type: Int32, key: "modifiedIndex", nilable: true},
        ttl: {type: Int32, nilable: true},
        key: {type: String, nilable: true},
        value: {type: String, nilable: true},
        expiration: {type: String, nilable: true},
        dir: {type: Bool, default: false},
        nodes: {type: Array(Node), key: "nodes", nilable: false, default: [] of Node}
      )

      def <=>(other : Node)
        key <=> other.key
      end

      def children
        if directory?
          nodes
        else
          raise "This is not a directory, cannot have children"
        end
      end

      def directory? : Bool
        dir
      end
    end
  end
end
