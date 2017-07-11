require 'redis'

module Workerholic

  class Storage

    class RedisWrapper
      attr_reader :redis

      def initialize(redis=Redis.new)
        @redis = redis
      end

      def pop(key)
        redis.lpop(key)
      end

      def push(key, value)
        redis.rpush(key, value)
      end

      def blpop(key, timeout = 0)
        redis.blpop(key, timeout)
      end
    end
  end

end
