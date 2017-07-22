require_relative 'log_manager'

module Workerholic
  class WorkerBalancer
    attr_reader :storage, :workers, :thread, :alive
    attr_accessor :queues

    def initialize(workers)
      @storage = Storage::RedisWrapper.new
      @queues = fetch_queues
      @workers = workers
      @alive = true
      @logger = LogManager.new
    end

    def start
      @thread = Thread.new do
        while alive
          self.queues = fetch_queues
          average_job_count_per_worker = total_jobs / workers.size.to_f

          counter = 0
          queues.each do |queue|
            counter += assign_workers_to_queue(queue, average_job_count_per_worker, counter)
          end

          if workers.size - counter == 1
            workers[workers.size - 1].queue = queues.sample unless queues.empty?
          end

          result = workers.reduce({}) do |r, worker|
            r[worker.queue.name] = r[worker.queue.name] ? r[worker.queue.name] + 1 : 1
            r
          end
          @logger.log('info', result)

          sleep 5
        end
      end
    end

    def kill
      thread.kill
    end

    def join
      thread.join
    end

    private

    def fetch_queues
      storage.fetch_queue_names.map { |queue_name| Queue.new(queue_name) }
    end

    def total_jobs
      @queues.map(&:size).reduce(:+) || 0
    end

    def assign_workers_to_queue(queue, average_job_count_per_worker, counter)
      workers_count = queue.size / average_job_count_per_worker

      if workers_count % 1 == 0.5
        workers_count = workers_count.floor
      else
        workers_count = workers_count.round
      end

      counter.upto(counter + workers_count - 1) do |i|
        workers.to_a[i].queue = Queue.new(queue.name)
      end

      workers_count - 1
    end
  end
end
