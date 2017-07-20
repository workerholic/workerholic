require_relative 'sorted_set'
require_relative 'queue'

module Workerholic
  class JobScheduler
    attr_reader :sorted_set, :set_name, :queue
    attr_accessor :alive

    def initialize(set_name = 'workerholic:scheduled_jobs', queue_name = 'workerholic:main')
      @sorted_set = SortedSet.new(set_name)
      @set_name = set_name
      @queue = Queue.new(queue_name)
      @alive = true
    end

    def start
      @scheduler_thread = Thread.new do
        while alive
          poll_scheduled
        end
      end
    end

    def job_due?
      job_execution_time = sorted_set.peek.last
      Time.now.to_f >= job_execution_time
    end

    def schedule(serialized_job, score)
      sorted_set.add(serialized_job, score)
    end

    def poll_scheduled
      if job_due?
        serialized_job, job_execution_time = sorted_set.peek
        sorted_set.remove(job_execution_time)
        queue.enqueue(serialized_job)
      else
        sleep(5)
      end
    end

    def join
      scheduler_thread.join
    end
  end
end
