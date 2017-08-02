module Workerholic
  # Handles polling from Redis and hands job to worker
  class Manager
    attr_reader :workers, :scheduler, :worker_balancer

    def initialize(opts = {})
      @workers = []
      Workerholic.workers_count.times { @workers << Worker.new }

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

      workers.each(&:join)
      scheduler.join
    end
  end
end
