require 'set'

require_relative 'worker'
require_relative 'job_scheduler'
require_relative 'worker_balancer'

module Workerholic
  # Handles polling from Redis and hands job to worker
  class Manager
    attr_reader :workers, :scheduler, :worker_balancer

    def initialize(workers_count = 50)
      raise ArgumentError, 'Invalid number of workers' if workers_count < 1

      @workers = []
      workers_count.times { @workers << Worker.new }

      @scheduler = JobScheduler.new
      @worker_balancer = WorkerBalancer.new(workers)
    end

    def start
      begin
        workers.each(&:work)
        worker_balancer.start
        scheduler.start

        sleep
      rescue SystemExit, Interrupt
        puts "\nWorkerholic is now shutting down. We are letting the workers finish their current jobs..."
        shutdown
        exit
      end
    end

    def shutdown
      workers.each(&:kill)
      workers.each(&:join)
      scheduler.kill
      scheduler.join
    end
  end
end
