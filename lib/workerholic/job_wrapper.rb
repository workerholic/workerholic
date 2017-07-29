module Workerholic
  class JobWrapper
    attr_accessor :retry_count, :execute_at
    attr_reader :klass, :arguments, :statistics, :wrapper

    def initialize(options={})
      @klass = options[:class]
      @wrapper = options[:wrapper]
      @arguments = options[:arguments]
      @execute_at = options[:execute_at]
      @retry_count = options[:retry_count] || 0
      @statistics = Statistics.new(options[:statistics] || {})
    end

    def to_hash
      {
        class: klass,
        wrapper: wrapper,
        arguments: arguments,
        retry_count: retry_count,
        execute_at: execute_at,
        statistics: statistics.to_hash
      }
    end

    def perform
      if wrapper == ActiveJob::QueueAdapters::WorkerholicAdapter::JobWrapper
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
