require 'redis'
require 'connection_pool'

module Workerholic
  class Storage
    # Wraps redis-rb gem methods for enqueueing/dequeuing purposes
    class RedisWrapper
      REDIS_POOL = ConnectionPool::Wrapper.new(size: 55, timeout: 10) { Redis.connect }

      attr_reader :redis, :retries

      def initialize
        @retries = 0
        @redis = REDIS_POOL
        redis.ping
      end

      def list_length(key)
        execute { redis.llen(key) }
      end

      def push(key, value)
        execute { redis.rpush(key, value) }
      end

      # blocking pop from Redis queue
      def pop(key, timeout = 1)
        execute { redis.blpop(key, timeout) }
      end

      def add_to_set(key, score, value)
        execute { redis.zadd(key, score, value) }
      end

      def peek(key)
        execute { redis.zrange(key, 0, 0, with_scores: true).first }
      end

      def remove_from_set(key, score)
        execute { redis.zremrangebyscore(key, score, score) }
      end

      def set_empty?(key)
        execute { redis.zcount(key, 0, '+inf') }
      end

      def fetch_queue_names
        redis.scan(0, match: 'workerholic:queue*').last
      end

      class RedisCannotRecover < Redis::CannotConnectError; end

      private

      def execute(&block)
        begin
          result = block.call
          reset_retries
        rescue Redis::CannotConnectError
          # LogManager might want to output our retries to the user
          @retries += 1
          if retries_exhausted?
            raise RedisCannotRecover, 'Redis reconnect retries exhausted. Main Workerholic thread will be terminated now.'
          end

          sleep(5)
          retry
        end

        result
      end

      def retries_exhausted?
        retries == 5
      end

      def reset_retries
        @retries = 0
      end
    end
  end
end
