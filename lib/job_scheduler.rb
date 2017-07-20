require_relative 'sorted_set'
require_relative 'queue'

module Workerholic
  class JobScheduler
    attr_reader :sorted_set, :set_name, :queue
    attr_accessor :alive

    def initialize(opts={})
      @sorted_set = SortedSet.new(opts[:set_name] || 'workerholic:scheduled_jobs')
      @set_name = set_name
      @queue = Queue.new(opts[:queue_name] || 'workerholic:main')
      @alive = true
    end

    def start
      @scheduler_thread = Thread.new do
        while alive
          enqueue_due_jobs
        end
      end
    end

    def job_due?
      job = sorted_set.peek

      if job
        job_execution_time = job.last
        Time.now.to_f >= job_execution_time
      end
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
  end
end
