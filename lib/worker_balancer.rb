module Workerholic
  class WorkerBalancer
    attr_reader :storage, :workers, :thread, :alive
    attr_accessor :queues

    def initialize(workers)
      @storage = Storage::RedisWrapper.new
      @queues = fetch_queues
      @workers = workers
      @alive = true
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

          result = Hash.new
          workers.reduce(result) do |r, worker|
            if r[worker.queue.name].nil?
              r[worker.queue.name] = 1
            else
              r[worker.queue.name] += 1
            end

            r
          end
          p result

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
      @queues.map(&:size).reduce(:+) || 0
    end

    def assign_workers_to_queue(queue, average_job_count_per_worker, counter)
      workers_count = (queue.size / average_job_count_per_worker).round
      counter.upto(counter + workers_count - 1) do |i|
        workers[i].queue = Queue.new(queue.name)
      end

      workers_count - 1
    end
  end
end
