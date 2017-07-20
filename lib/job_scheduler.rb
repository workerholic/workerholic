require_relative 'sorted_set'
require_relative 'queue'

module Workerholic
  class JobScheduler
    attr_reader :sorted_set, :queue, :scheduler_thread
    attr_accessor :alive

    def initialize(opts={})
      @sorted_set = SortedSet.new(opts[:set_name] || 'workerholic:scheduled_jobs')
      @queue = Queue.new(opts[:queue_name] || 'workerholic:main')
      @alive = true
    end

    def start
      @scheduler_thread = Thread.new do
        enqueue_due_jobs while alive
      end
    end

    def job_due?
      scheduled_job = sorted_set.peek
      return false unless scheduled_job

      job_execution_time = scheduled_job.last
      return Time.now.to_f >= job_execution_time
    end

    def schedule(serialized_job, score)
      sorted_set.add(serialized_job, score)
    end

    def enqueue_due_jobs
      if job_due?
        while job_due?
          serialized_job, job_execution_time = sorted_set.peek
          sorted_set.remove(job_execution_time)
          queue.enqueue(serialized_job)
        end
      else
        sleep(5)
      end
    end

    def join
      scheduler_thread.join
    end

    def kill
      self.alive = false
    end
  end
end
