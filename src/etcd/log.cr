require "logger"

module Etcd
  class Log

    INSTANCE = new

    forward_missing_to @logger

    def initialize
      @logger = Logger.new(STDOUT)
    end

    def self.configure
      yield INSTANCE
    end

    def self.error(msg)
      INSTANCE.error(msg)
    end

    def self.warn(msg)
      INSTANCE.warn(msg)
    end

    def self.info(msg)
      INSTANCE.info(msg)
    end

    def self.debug(msg)
      INSTANCE.debug(msg)
    end
  end
end
