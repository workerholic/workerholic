module Workerholic
  class Storage
    # Wraps redis-rb gem methods for enqueueing/dequeuing purposes
    class RedisWrapper
      attr_reader :redis, :retries

      def initialize
        @retries = 0
        @redis = Workerholic.redis_pool

        redis.with do |conn|
          conn.ping
        end
      end

      def list_length(key)
        execute { |conn| conn.llen(key) }
      end

      def push(key, value)
        execute { |conn| conn.rpush(key, value) }
      end

      # blocking pop from Redis queue
      def pop(key, timeout = 1)
        execute { |conn| conn.blpop(key, timeout) }
      end

      def add_to_set(key, score, value)
        execute { |conn| conn.zadd(key, score, value) }
      end

      def peek(key)
        execute { |conn| conn.zrange(key, 0, 0, with_scores: true).first }
      end

      def remove_from_set(key, score)
        execute { |conn| conn.zremrangebyscore(key, score, score) }
      end

      def set_empty?(key)
        execute { |conn| conn.zcount(key, 0, '+inf') }
      end

      def fetch_queue_names
        execute { |conn| conn.scan(0, match: 'workerholic:queue*').last }
      end

      def add_job_stats(key, value)
        execute { |conn| conn.rpush(key, value) }
      end

      def get_jobs_stats(key)
        execute { |conn| conn.lrange(key, 0, -1) }
      end

      class RedisCannotRecover < Redis::CannotConnectError; end

      private

      def execute
        begin
          result = redis.with { |conn| yield conn }
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
