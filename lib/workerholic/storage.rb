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

      def list_length(key, retry_delay = 5)
        execute(retry_delay) { |conn| conn.llen(key) }
      end

      def push(key, value, retry_delay = 5)
        execute(retry_delay) { |conn| conn.rpush(key, value) }
      end

      # blocking pop from Redis queue
      def pop(key, timeout = 1, retry_delay = 5)
        execute(retry_delay) { |conn| conn.blpop(key, timeout) }
      end

      def add_to_set(key, score, value, retry_delay = 5)
        execute(retry_delay) { |conn| conn.zadd(key, score, value) }
      end

      def peek(key, retry_delay = 5)
        execute(retry_delay) { |conn| conn.zrange(key, 0, 0, with_scores: true).first }
      end

      def remove_from_set(key, score, retry_delay = 5)
        execute(retry_delay) { |conn| conn.zremrangebyscore(key, score, score) }
      end

      def sorted_set_size(key, retry_delay = 5)
        execute(retry_delay) { |conn| conn.zcount(key, 0, '+inf') }
      end

      def keys_count(namespace, retry_delay = 5)
        execute(retry_delay) { |conn| conn.keys(namespace + ':*').size }
      end

      def fetch_queue_names(retry_delay = 5)
        queue_name_pattern = $TESTING ? 'workerholic:testing:queue*' : 'workerholic:queue*'

        execute(retry_delay) { |conn| conn.scan(0, match: queue_name_pattern).last }
      end

      def available_keys(retry_delay = 5)
        execute(retry_delay) { |conn| conn.keys('workerholic:stats:*') }
      end

      def keys_for_namespace(namespace, retry_delay = 5)
        execute(retry_delay) { |conn| conn.keys('workerholic:stats:' + namespace + ':*') }
      end

      def peek_namespace(key, retry_delay = 5)
        execute(retry_delay) { |conn| conn.lrange(key, 0, -1) }
      end

      def peek_namespaces(keys, retry_delay = 5)
        execute(retry_delay) do |conn|
          keys.select do |namespace|
            full_namespace = 'workerholic:stats:' + namespace
            conn.keys(full_namespace + ':*').size > 0
          end
        end
      end

      class RedisCannotRecover < Redis::CannotConnectError; end

      private

      def execute(retry_delay = 5)
        begin
          result = redis.with { |conn| yield conn }
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
