require_relative 'storage'

module Workerholic
  class Queue
    @storage = Storage::RedisWrapper.new

    def self.enqueue(queue_name = 'default', serialized_job)
      @storage.push(queue_name, serialized_job)
    end
  end
end
