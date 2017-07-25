require 'set'

require_relative 'worker'
require_relative 'job_scheduler'
require_relative 'worker_balancer'

module Workerholic
  # Handles polling from Redis and hands job to worker
  class Manager
    WORKERS_COUNT = 25

    attr_reader :workers, :scheduler, :worker_balancer

    def initialize(opts = {})
      raise ArgumentError, 'Invalid number of workers' if WORKERS_COUNT < 1

      @workers = []
      WORKERS_COUNT.times { @workers << Worker.new }

      @scheduler = JobScheduler.new
      @worker_balancer = WorkerBalancer.new(workers: workers, auto_balance: opts[:auto_balance])
    end

    def start
      worker_balancer.start
      workers.each(&:work)
      scheduler.start
      sleep
    rescue SystemExit, Interrupt
      puts "\nWorkerholic is now shutting down. We are letting the workers finish their current jobs..."
      shutdown
      exit
    end

    def shutdown
      workers.each(&:kill)
      worker_balancer.kill
      scheduler.kill
    end
  end
end
