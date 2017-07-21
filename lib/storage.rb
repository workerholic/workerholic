require 'redis'
require 'connection_pool'

module Workerholic
  class Storage
    class RedisNotRunningError < StandardError; end

    # Wraps redis-rb gem methods for enqueueing/dequeuing purposes
    class RedisWrapper
      attr_reader :redis
      attr_accessor :retries

      def initialize
        @redis = ConnectionPool::Wrapper.new(size: 12, timeout: 10) { Redis.connect }
        @retries = 0
        redis.ping
      end

      def list_length(key)
        begin
          jobs_count = redis.llen(key)
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

        jobs_count
      end

      def push(key, value)
        begin
          redis.rpush(key, value)
          reset_retries
        rescue Redis::CannotConnectError
          # LogManager might want to output our retries to the user or store them for statistics
          @retries += 1
          if retries_exhausted?
            raise RedisCannotRecover, 'Redis reconnect retries exhausted. Main Workerholic thread will be terminated now.'
          end

          sleep(5)
          retry
        end
      end

      # blocking pop from Redis queue
      def pop(key, timeout = 1)
        redis.blpop(key, timeout)
      end

      def add_to_set(key, score, value)
        begin
          redis.zadd(key, score, value)
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
      end

      def peek(key)
        begin
          job = redis.zrange(key, 0, 0, with_scores: true).first
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

        job
      end

      def remove_from_set(key, score)
        begin
          redis.zremrangebyscore(key, score, score)
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
      end

      def set_empty?(key)
        begin
          jobs_count = redis.zcount(key, 0, '+inf')
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

        jobs_count
      end

      class RedisCannotRecover < Redis::CannotConnectError; end

      private

      def retries_exhausted?
        retries == 5
      end

      def reset_retries
        @retries = 0
      end
    end
  end
end
