module Workerholic

  class Worker

    def initialize
      @storage = Storage::RedisWrapper.new
    end

    def deserialize_job(job)
      ::YAML.load(job)
    end

    def work(serialized_job)
      components = deserialize_job(serialized_job)
      job_class, job_args = components.first, components.last
      job_class.new.perform(*job_args)
    end
  end
end
