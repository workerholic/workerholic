module Workerholic
  class Storage
    class RedisWrapper
      attr_reader :redis, :retries

      def initialize
        @retries = 0
        @redis = Workerholic.redis_pool

        redis.with do |conn|
          conn.ping
        end
      end

      def hash_set(key, field, value, retry_delay = 5)
        execute(retry_delay) { |conn| conn.hset(key, field, value) }
      end

      def hash_get(key, field, retry_delay = 5)
        execute(retry_delay) { |conn| conn.hget(key, field) }
      end

      def hash_get_all(key, retry_delay = 5)
        execute(retry_delay) { |conn| conn.hgetall(key) }
      end

      def hash_keys(namespace, retry_delay = 5)
        execute(retry_delay) { |conn| conn.hkeys(namespace) }
      end

      def delete(key, retry_delay = 5)
        execute(retry_delay) { |conn| conn.del(key) }
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

      def hash_increment_field(key, field, increment, retry_delay = 5)
        execute(retry_delay) { |conn| conn.hincrby(key, field, increment) }
      end

      def sorted_set_size(key, retry_delay = 5)
        execute(retry_delay) { |conn| conn.zcount(key, 0, '+inf') }
      end

      def sorted_set_members(key, retry_delay = 5)
        execute(retry_delay) { |conn| conn.zrange(key, 0, -1) }
      end

      def sorted_set_members_count(key, retry_delay = 5)
        execute(retry_delay) { |conn| conn.zcard(key) }
      end

      def keys_count(namespace, retry_delay = 5)
        execute(retry_delay) { |conn| conn.keys(namespace + ':*').size }
      end

      def fetch_queue_names(retry_delay = 5)
        queue_name_pattern = 'workerholic:queue*'

        execute(retry_delay) { |conn| conn.scan(0, match: queue_name_pattern).last }
      end

      def get_keys_for_namespace(namespace, retry_delay = 5)
        execute(retry_delay) { |conn| conn.keys(namespace) }
      end

      def get_all_elements_from_list(key, retry_delay = 5)
        execute(retry_delay) { |conn| conn.lrange(key, 0, -1) }
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
