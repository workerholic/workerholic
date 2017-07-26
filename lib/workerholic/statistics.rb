module Workerholic
  class Statistics
    attr_accessor :enqueued_at, :retry_count, :errors, :started_at, :completed_at, :failed_on, :elapsed_time

    def initialize(options={})
      @enqueued_at = options[:enqueued_at]
      @errors = options[:errors] || []
      @started_at = options[:started_at]
      @completed_at = options[:completed_at]
    end

    def to_hash
      {
        enqueued_at: enqueued_at,
        errors: errors,
        started_at: started_at,
        completed_at: completed_at,
        elapsed_time: elapsed_time,
        failed_on: failed_on
      }
    end

    def set_elapsed_time
      @elapsed_time = completed_at - started_at
    end
  end
end
