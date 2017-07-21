require_relative 'storage'
require_relative 'log_manager'

module Workerholic
  # Handles background job enqueueing/dequeuing functionality
  class Queue
    attr_reader :storage, :name

    def initialize(name = 'workerholic:queue:main')
      @storage = Storage::RedisWrapper.new
      @name = name
      @log_manager = LogManager.new
    end

    def enqueue(serialized_job)
      storage.push(name, serialized_job)
      @log_manager.log('info', "Your job was placed in the #{name} queue on #{Time.now}.")
    end

    def dequeue
      storage.pop(name).last
    end

    def empty?
      storage.list_length(name).zero?
    end
  end
end
