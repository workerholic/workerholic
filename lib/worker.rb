module Workerholic

  # handles job execution in threads
  class Worker
    def initialize
      @storage = Storage::RedisWrapper.new
      @dead = false
    end

    def deserialize_job(job)
      ::YAML.load(job)
    end

    def create_thread
      @thread = Thread.new do
        while !@dead
          poll
        end
      end
    end

    def work
      create_thread
    end

    def join
      @thread.join
    end

    private

    def poll(queue_name = 'default')
      serialized_job = @storage.pop(queue_name, 0).last
      process(serialized_job)
    end

    def process(serialized_job)
      components = deserialize_job(serialized_job)
      job_class, job_args = components.first, components.last
      job_class.new.perform(*job_args)
    end
  end
end
