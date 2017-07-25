require_relative 'log_manager'

module Workerholic
  class WorkerBalancer
    attr_reader :storage, :workers, :thread, :alive, :auto
    attr_accessor :queues

    def initialize(opts = {})
      @storage = Storage::RedisWrapper.new
      @queues = fetch_queues
      @workers = opts[:workers] || []
      @alive = true
      @logger = LogManager.new
      @auto = opts[:auto_balance]
    end

    def start
      if auto
        auto_balance_workers
      else
        evenly_balance_workers
      end
    end

    def kill
      thread.kill
      thread.join
    end

    private

    def auto_balance_workers
      @thread = Thread.new do
        while alive
          self.queues = fetch_queues

          counter = 0
          while counter < queues.size
            workers[counter].queue = queues[counter]
            counter += 1
          end

          remaining_workers_count = workers.size - (counter + 1)
          average_job_count_per_worker = total_jobs / remaining_workers_count.to_f

          queues.each do |queue|
            workers_count = queue.size / average_job_count_per_worker

            if workers_count % 1 == 0.5
              workers_count = workers_count.floor
            else
              workers_count = workers_count.round
            end

            assign_workers_to_queue(queue, workers_count, counter)

            counter += workers_count
          end

          workers[workers.size - 1].queue = queues.sample if workers.size - counter == 1

          @logger.log('info', queues.map { |q| { name: q.name, size: q.size } })
          @logger.log('info', current_workers_count_per_queue)

          sleep 2
        end
      end
    end

    def evenly_balance_workers
      @thread = Thread.new do
        while alive
          self.queues = fetch_queues

          counter = 0
          while counter < queues.size
            workers[counter].queue = queues[counter]
            counter += 1
          end

          remaining_workers_count = workers.size - (counter + 1)
          queues.each do |queue|
            workers_count = remaining_workers_count / queues.size
            assign_workers_to_queue(queue, workers_count, counter)
            counter += workers_count
          end

          workers[workers.size - 1].queue = queues.sample if workers.size - counter == 1

          @logger.log('info', queues.map { |q| { name: q.name, size: q.size } })
          @logger.log('info', current_workers_count_per_queue)

          sleep 2
        end
      end
    end

    def fetch_queues
      storage.fetch_queue_names.map { |queue_name| Queue.new(queue_name) }
    end

    def total_jobs
      @queues.map(&:size).reduce(:+) || 0
    end

    def assign_workers_to_queue(queue, workers_count, counter)
      counter.upto(counter + workers_count - 1) do |i|
        workers.to_a[i].queue = Queue.new(queue.name)
      end
    end

    def current_workers_count_per_queue
      workers.reduce({}) do |result, worker|
        result[worker.queue.name] = result[worker.queue.name] ? result[worker.queue.name] + 1 : 1
        result
      end
    end
  end
end
