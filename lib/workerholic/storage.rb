module Workerholic
  class Storage
    # Wraps redis-rb gem methods for enqueueing/dequeuing purposes
    class RedisWrapper
      REDIS_POOL = ConnectionPool::Wrapper.new(size: 30, retry_delay: 10) { Redis.connect }

      attr_reader :redis, :retries

      def initialize
        @retries = 0
        @redis = REDIS_POOL
        redis.ping
      end

      def list_length(key)
        execute { redis.llen(key) }
      end

      def push(key, value, retry_delay = 5)
        execute(retry_delay) { redis.rpush(key, value) }
      end

      # blocking pop from Redis queue
      def pop(key, timeout = 1, retry_delay = 5)
        execute(retry_delay) { redis.blpop(key, timeout) }
      end

      def add_to_set(key, score, value, retry_delay = 5)
        execute(retry_delay) { redis.zadd(key, score, value) }
      end

      def peek(key, retry_delay = 5)
        execute(retry_delay) { redis.zrange(key, 0, 0, with_scores: true).first }
      end

      def remove_from_set(key, score, retry_delay = 5)
        execute(retry_delay) { redis.zremrangebyscore(key, score, score) }
      end

      def set_empty?(key, retry_delay = 5)
        execute(retry_delay) { redis.zcount(key, 0, '+inf') }
      end

      def fetch_queue_names(retry_delay = 5)
        execute(retry_delay) { redis.scan(0, match: 'workerholic:queue*').last }
      end

      class RedisCannotRecover < Redis::CannotConnectError; end

      private

      def execute(retry_delay = 5, &block)
        begin
          result = block.call if block_given?
          reset_retries
        rescue Redis::CannotConnectError
          @retries += 1
          if retries_exhausted?
            raise RedisCannotRecover, 'Redis reconnect retries exhausted. Main Workerholic thread will be terminated now.'
          end

          sleep retry_delay
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
