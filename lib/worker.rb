require 'yaml'

require_relative 'job_processor'
require_relative 'queue'

module Workerholic
  # handles job execution in threads
  class Worker
    attr_reader :thread
    attr_accessor :alive, :queue

    def initialize(queue=Queue.new)
      @queue = queue
      @alive = true
    end

    def work
      @thread = Thread.new do
        while alive
          serialized_job = poll
          JobProcessor.new(serialized_job).process if serialized_job
        end

        puts "DONE!"
      end
    end

    def join
      thread.join
    end

    def kill
      self.alive = false
    end

    private

    def poll
      queue.dequeue
    end
  end
end
