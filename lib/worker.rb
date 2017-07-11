module Workerholic

  class Worker

    def initialize
      @storage = Storage::RedisWrapper.new
    end

    def deserialize_job(job)
      ::YAML.load(job)
    end

    def poll(queue_name = 'default')
      loop do
        current_serialized_job = @storage.pop(queue_name)
        break if current_serialized_job.nil?

        current_job_components = deserialize_job(current_serialized_job)

        job_class = current_job_components.first
        job_args = current_job_components.last

        job_class.new.perform(*job_args)
      end
    end

  end

end
