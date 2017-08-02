module Workerholic
  class JobScheduler
    attr_reader :sorted_set, :scheduler_thread
    attr_accessor :alive

    def initialize(opts={})
      @sorted_set = opts[:sorted_set] || SortedSet.new
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
      Time.now.to_f >= job_execution_time
    end

    def schedule(serialized_job, score)
      sorted_set.add(serialized_job, score)
    end

    def enqueue_due_jobs
      if job_due?
        while job_due?
          serialized_job, job_execution_time = sorted_set.peek
          job = JobSerializer.deserialize(serialized_job)
          queue = job.queue ? Queue.new(job.queue) : Queue.new

          queue.enqueue(serialized_job)

          sorted_set.remove(job_execution_time)
        end
      else
        sleep(2)
      end
    end

    def kill
      self.alive = false
    end

    def join
      scheduler_thread.join if scheduler_thread
    end
  end
end
