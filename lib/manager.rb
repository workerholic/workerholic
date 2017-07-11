require_relative 'storage'
require_relative 'worker'

module Workerholic
  class Manager
    @storage = Storage::RedisWrapper.new
    @worker = Worker.new

=begin
    def self.poll(queue_name = 'default')
      loop do
        current_serialized_job = @storage.pop(queue_name)
        if current_serialized_job.nil?
          sleep(0.5)
          next
        end

        current_job_components = deserialize_job(current_serialized_job)

        job_class = current_job_components.first
        job_args = current_job_components.last

        job_class.new.perform(*job_args)
      end
    end
=end

    def self.blpoll(queue_name = 'default')
      loop do
        serialized_job = @storage.blpop(queue_name, 0).last
        @worker.work(serialized_job)
      end
    end
  end
end
