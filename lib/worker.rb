module Workerholic

  # handles job execution in threads
  class Worker
    @@counter = 0
    def initialize
      @storage = Storage::RedisWrapper.new
    end

    def deserialize_job(job)
      ::YAML.load(job)
    end

    def work(serialized_job)
      components = deserialize_job(serialized_job)
      job_class, job_args = components.first, components.last
      Thread.new { job_class.new.perform(*job_args) }
    end

  end
end
