module Etcd
  module Stats
    class Leader
      JSON.mapping(
        followers: Hash(String, Follower),
        leader: String
      )

      class Follower
        class Counts
          JSON.mapping(
            fail: Int32,
            success: Int32
          )
        end

        class Latency
          JSON.mapping(
            average: Float32,
            current: Float32,
            maximum: Float32,
            minimum: Float32,
            standard_deviation: {type: Float32, key: "standardDeviation"}
          )
        end

        JSON.mapping(
          counts: Follower::Counts,
          latency: Follower::Latency
        )
      end
    end
  end
end
