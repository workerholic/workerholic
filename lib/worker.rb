require 'yaml'

module Workerholic
  # handles job execution in threads
  class Worker
    attr_reader :queue, :dead, :thread

    def initialize
      @queue = Queue.new
      @dead = false
    end

    def work
      @thread = Thread.new do
        while !dead
          serialized_job = poll
          process(serialized_job)
        end
      end
    end

    def join
      @thread.join
    end

    private

    def poll
      @queue.dequeue
    end

    def process(serialized_job)
      components = deserialize_job(serialized_job)
      job_class, job_args = components.first, components.last
      job_class.new.perform(*job_args)
    end

    def deserialize_job(job)
      ::YAML.load(job)
    end
  end
end
