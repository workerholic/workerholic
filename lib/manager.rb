require_relative 'worker'

module Workerholic
  # Handles polling from Redis and hands job to worker
  class Manager
    attr_reader :workers

    def initialize(workers_count = 10)
      @workers = Array.new(workers_count, Worker.new)
    end

    def start
      workers.each(&:work)
    end
  end
end
