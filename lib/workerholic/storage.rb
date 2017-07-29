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
        execute { |conn| conn.keys('workerholic:queue*') }
      end

      def keys_count(namespace)
        execute { |conn| conn.keys(namespace + ':*').size }
      end

      def get_stats(namespace)
        execute do |conn|
          job_classes = conn.keys(namespace + ":*")
          jobs_stats = []

          job_classes.each do |job_class|
            clean_class_name = job_class.split(':').last
            jobs_stats << [clean_class_name, conn.lrange(job_class, 0, -1)]
          end

          jobs_stats
        end
      end

      def get_classes(namespaces)
        execute do |conn|
          unique_classes = []

          namespaces.each do |namespace|
            available_classes = conn.keys(namespace + ':*')
            if available_classes.size > 0
              # extract actual class name from the namespace
              available_classes.each do |klass|
                clean_class_name = klass.split(':').last
                unique_classes << clean_class_name
              end
            end
          end

          unique_classes.uniq
        end
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
