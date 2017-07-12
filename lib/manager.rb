require_relative 'storage'
require_relative 'worker'

module Workerholic
  # Handles polling from Redis and hands job to worker
  class Manager
    @storage = Storage::RedisWrapper.new
    @worker = Worker.new

    def self.poll(queue_name = 'default')
      loop do
        serialized_job = @storage.pop(queue_name, 0).last
        @worker.work(serialized_job)
      end
    end
  end
end
