require_relative 'storage'

module Workerholic
  # Handles background job enqueueing/dequeuing functionality
  class Queue
    attr_reader :storage, :name

    def initialize(name = 'workerholic:main')
      @storage = Storage::RedisWrapper.new
      @name = name
    end

    def enqueue(serialized_job)
      storage.push(name, serialized_job)
    end

    def dequeue
      storage.pop(name).last
    end
  end
end
