module Workerholic
  # Handles polling from Redis and hands job to worker
  class Manager
    attr_reader :workers, :scheduler, :worker_balancer, :logger

    def initialize(opts = {})
      @workers = []
      Workerholic.workers_count.times { @workers << Worker.new }

      @scheduler = JobScheduler.new(sorted_set: opts[:sorted_set])
      @worker_balancer = WorkerBalancer.new(workers: workers, auto_balance: opts[:auto_balance])

      @logger = LogManager.new
    end

    def start
      worker_balancer.start
      workers.each(&:work)
      scheduler.start

      sleep
    rescue SystemExit, Interrupt
      logger.info("Workerholic's process #{Process.pid} is gracefully shutting down, letting workers finish their current jobs...")
      shutdown

      exit
    end

    def shutdown
      workers.each(&:kill)
      worker_balancer.kill
      scheduler.kill
      Starter.kill_memory_tracker_thread

      workers.each(&:join)
      scheduler.join
    end
  end
end
