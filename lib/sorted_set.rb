require_relative 'storage'

module Workerholic
  class SortedSet
    attr_reader :storage

    def initialize
      @storage = Storage::RedisWrapper.new
    end

    def add(serialized_job)
      storage.zadd(name, Time.now.to_f, serialized_job)
    end

    def pop
      job = storage.zrange(name, 0, 0, limit: [0, 1], with_scores: true).first

      if Time.now.to_f >= job.last
        if storage.zrem(latest_job.first)
          latest_job.first
        else
          nil
        end
      end
    end
  end
end
