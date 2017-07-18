require 'redis'

module Workerholic
  class Storage
    class RedisNotRunningError < StandardError; end

    # Wraps redis-rb gem methods for enqueueing/dequeuing purposes
    class RedisWrapper
      attr_reader :redis

      def initialize
        @redis = Redis.new
        redis.ping
      end

      def push(key, value)
        redis.rpush(key, value)
      end

      # blocking pop from Redis queue
      def pop(key, timeout = 0)
        redis.blpop(key, timeout)
      end
    end
  end
end
