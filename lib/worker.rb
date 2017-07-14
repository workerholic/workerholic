require 'yaml'

require_relative 'job_processor'

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
          # process(serialized_job)
          JobProcessor.new(serialized_job).process
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
  end
end
