require "json"

module Etcd

  class Error < Exception

    JSON.mapping(
      message: {type: String, nilable: true},
      reason: {type: String, key: "cause", nilable: true},
      index: Int32,
      error_code: {type: Int16, key: "errorCode"}
    )

    def self.from_http_response(response : HTTP::Client::Response) : Error
      error = self.from_json(response.body)
      unless ERROR_CODE_MAPPING.has_key?(error.error_code)
        raise "unknown error code: #{error.error_code}"
      end

      coded_error = ERROR_CODE_MAPPING[error.error_code].from_json(response.body)
      coded_error.message = error.message
      coded_error.reason = error.reason
      coded_error.index = error.index
      coded_error.error_code = error.error_code

      coded_error
    end

    def inspect
      "<#{self.class.name}: index:#{index}, code:#{error_code}, reason:'#{reason}'>"
    end
  end

  # command related error
  class KeyNotFound < Error; end
  class TestFailed < Error; end
  class NotFile < Error; end
  class NoMorePeer < Error; end
  class NotDir < Error; end
  class NodeExist < Error; end
  class KeyIsPreserved < Error; end
  class DirNotEmpty < Error; end

  # Post form related error
  class ValueRequired < Error; end
  class PrevValueRequired < Error; end
  class TTLNaN < Error; end
  class IndexNaN < Error; end

  # Raft related error
  class RaftInternal < Error; end
  class LeaderElect < Error; end

  # Etcd related error
  class WatcherCleared < Error; end
  class EventIndexCleared < Error; end

  ERROR_CODE_MAPPING = {
    # command related error
    100 => KeyNotFound,
    101 => TestFailed,
    102 => NotFile,
    103 => NoMorePeer,
    104 => NotDir,
    105 => NodeExist,
    106 => KeyIsPreserved,
    108 => DirNotEmpty,

    # Post form related error
    200 => ValueRequired,
    201 => PrevValueRequired,
    202 => TTLNaN,
    203 => IndexNaN,

    # Raft related error
    300 => RaftInternal,
    301 => LeaderElect,

    # Etcd related error
    400 => WatcherCleared,
    401 => EventIndexCleared
  }
end
