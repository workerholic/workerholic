module Workerholic
  class JobStatistics

    attr_accessor :enqueued_at,
                  :errors,
                  :started_at,
                  :completed_at,
                  :failed_on

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

    def elapsed_time
      if completed_at && started_at
        format_elapsed_time(completed_at - started_at)
      end
    end

    def format_elapsed_time(time)
      '%.10f' % time
    end
  end
end
