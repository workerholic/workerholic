module Workerholic
  class JobWrapper
    attr_accessor :retry_count, :execute_at
    attr_reader :klass, :arguments, :statistics, :wrapper, :queue

    def initialize(options={})
      @klass = options[:klass]
      @wrapper = options[:wrapper]
      @arguments = options[:arguments]
      @queue = options[:queue]
      @execute_at = options[:execute_at]
      @retry_count = options[:retry_count] || 0
      @statistics = JobStatistics.new(options[:statistics] || {})
    end

    def to_hash
      {
        klass: klass,
        wrapper: wrapper,
        arguments: arguments,
        queue: queue,
        retry_count: retry_count,
        execute_at: execute_at,
        statistics: statistics.to_hash
      }
    end

    def perform
      if wrapper && wrapper.name == 'ActiveJob::QueueAdapters::WorkerholicAdapter::JobWrapper'
        wrapper.new.perform(
          'job_class' => klass,
          'arguments' => arguments
        )
      else
        klass.new.perform(*arguments)
      end
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end
end
