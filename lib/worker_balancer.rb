module Workerholic
  class WorkerBalancer
    attr_reader :storage, :workers, :thread
    attr_accessor :queues

    def initialize(workers)
      @storage = Storage::RedisWrapper.new
      @queues = fetch_queues
      @workers = workers
    end

    def start
      @thread = Thread.new do
        puts "BALANCING WORKERS!"
        loop do
          self.queues = fetch_queues
          average_job_count_per_worker = total_jobs / workers.size.to_f
          puts "BALANCING WORKERS! #{average_job_count_per_worker}"

          queues.each do |queue|
            assign_workers_to_queue(queue, average_job_count_per_worker)
          end

          sleep 10
        end
      end
    end

    def kill
      thread.kill
    end

    private

    def fetch_queues
      storage.fetch_queue_names.map { |queue_name| Queue.new(queue_name) }
    end

    def total_jobs
      @queues.map(&:size).reduce(:+)
    end

    def assign_workers_to_queue(queue, average_job_count_per_worker)
      workers_count = queue.size / average_job_count_per_worker
      0.upto(workers_count - 1) do |i|
        workers[i].queue = queue
      end
    end
  end
end
