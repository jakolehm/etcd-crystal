module Etcd
  module Stats
    class SelfInfo
      JSON.mapping(
        id: String,
        leader_info: {type: Hash(String, String), key: "leaderInfo"},
        name: String,
        recv_append_request_count: {type: Int64, key: "recvAppendRequestCnt"},
        send_append_request_count: {type: Int64, key: "sendAppendRequestCnt"},
        send_pkg_rate: {type: Float64, key: "sendPkgRate", nilable: true},
        start_time: {type: String, nilable: true},
        state: String
      )
    end
  end
end
