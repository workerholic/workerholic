require_relative 'worker'
require_relative 'job_scheduler'

module Workerholic
  # Handles polling from Redis and hands job to worker
  class Manager
    attr_reader :workers, :scheduler

    def initialize(workers_count = 25)
      @workers = Array.new(workers_count, Worker.new)
      @scheduler = JobScheduler.new
    end

    def start
      workers.each(&:work)
      scheduler.start.join
      #workers.each(&:join)
    end
  end
end
