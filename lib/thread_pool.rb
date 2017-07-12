module Workerholic
  # A thread pool with a maximum of 10 threads
  class ThreadPool
    attr_accessor :pool

    def initialize
      @pool = []
      fill
    end

    def fill
      10.times do
        @pool << create_thread
      end
    end

    def empty?
      @pool.empty?
    end

    private

    def create_thread
      Thread.new do
        Thread.stop
        # job_class = nil
        # job_args = nil

        while true
          job_class = Thread.current.thread_variable_get(:job_class)
          job_args = Thread.current.thread_variable_get(:job_args)
          job_class.new.perform(*job_args)
          @pool << Thread.current
          Thread.stop
        end
      end
    end

  end
end
