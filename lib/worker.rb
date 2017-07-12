require_relative 'thread_pool'

module Workerholic

  # handles job execution in threads
  class Worker
    @@counter = 0
    def initialize
      @storage = Storage::RedisWrapper.new
      @thread_pool = ThreadPool.new
    end

    def deserialize_job(job)
      ::YAML.load(job)
    end

    def work(serialized_job)
      components = deserialize_job(serialized_job)
      job_class, job_args = components.first, components.last
      # Thread.new { job_class.new.perform(*job_args) }
      worker_thread = @thread_pool.pool.pop
      worker_thread.thread_variable_set(:job_class, job_class)
      worker_thread.thread_variable_set(:job_args, job_args)
      worker_thread.run
    end

  end
end
