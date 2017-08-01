module Workerholic
  # Handles polling from Redis and hands job to worker
  class Manager
    attr_reader :workers, :scheduler, :worker_balancer, :logger

    def initialize(opts = {})
      @workers = []
      50.times { @workers << Worker.new }

      @scheduler = JobScheduler.new
      @worker_balancer = WorkerBalancer.new(workers: workers, auto_balance: opts[:auto_balance])

      @logger = LogManager.new
    end

    def start
      worker_balancer.start
      workers.each(&:work)
      scheduler.start

      sleep
    rescue SystemExit, Interrupt
      # Signal.trap('INT') {}

      logger.info("Workerholic's process #{Process.pid} is now shutting down...")
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

    private

=begin
    def regenerate_workers
      inactive_workers = WORKERS_COUNT - workers.size
      if inactive_workers > 0
        inactive_workers.times { @workers << Worker.new }
      end
    end
=end
  end
end
