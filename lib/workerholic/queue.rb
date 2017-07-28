module Workerholic
  # Handles background job enqueueing/dequeuing functionality
  class Queue
    attr_reader :storage, :name, :logger

    def initialize(name = 'workerholic:queue:main')
      @storage = Storage::RedisWrapper.new
      @name = name
      @logger = LogManager.new
    end

    def enqueue(serialized_job)
      storage.push(name, serialized_job)
      logger.info("Your job was placed in the #{name} queue on #{Time.now}.")
    end

    def dequeue
      job_info = storage.pop(name)
      job_info.last if job_info
    end

    def empty?
      storage.list_length(name) == 0
    end

    def size
      storage.list_length(name)
    end
  end
end
