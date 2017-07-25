require 'yaml'

require_relative 'job_processor'
require_relative 'queue'

module Workerholic
  # handles job execution in threads
  class Worker
    attr_reader :thread
    attr_accessor :alive, :queue

    def initialize(queue=nil)
      @queue = queue
      @alive = true
      @logger = LogManager.new
    end

    def work
      Thread.abort_on_exception = true
      @thread = Thread.new do
        raise ThreadError
        while alive
          serialized_job = poll
          JobProcessor.new(serialized_job).process if serialized_job
        end

        puts "DONE!"
      end
    rescue ThreadError => e
      @logger.log('info', e.message)
      raise Interrupt
    end

    def kill
      self.alive = false
      thread.join if thread
    end

    private

    def poll
      if queue
        queue.dequeue
      else
        sleep 0.1
        nil
      end
    end
  end
end
