require 'redis'
require 'connection_pool'

module Workerholic
  class Storage
    class RedisNotRunningError < StandardError; end

    # Wraps redis-rb gem methods for enqueueing/dequeuing purposes
    class RedisWrapper
      attr_reader :redis

      def initialize
        @redis = ConnectionPool::Wrapper.new(size: 12, timeout: 10) { Redis.connect }
        redis.ping
      end

      def list_length(key)
        redis.llen(key)
      end

      def push(key, value)
        redis.rpush(key, value)
      end

      # blocking pop from Redis queue
      def pop(key, timeout = 1)
        redis.blpop(key, timeout)
      end

      def add_to_set(key, score, value)
        redis.zadd(key, score, value)
      end

      def peek(key)
        redis.zrange(key, 0, 0, with_scores: true).first
      end

      def remove_from_set(key, score)
        redis.zremrangebyscore(key, score, score)
      end

      def set_empty?(key)
        redis.zcount(key, 0, '+inf')
      end
    end
  end
end
