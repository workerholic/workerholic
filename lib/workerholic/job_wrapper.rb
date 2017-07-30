module Workerholic
  class JobWrapper
    attr_accessor :retry_count, :execute_at
    attr_reader :klass, :arguments, :statistics

    def initialize(options={})
      @klass = options[:klass]
      @arguments = options[:arguments]
      @execute_at = options[:execute_at]
      @retry_count = options[:retry_count] || 0
      @statistics = JobStatistics.new(options[:statistics] || {})
    end

    def to_hash
      {
        klass: klass,
        arguments: arguments,
        retry_count: retry_count,
        execute_at: execute_at,
        statistics: statistics.to_hash
      }
    end

    def perform
      klass.new.perform(*arguments)
    end

    def ==(other)
      to_hash == other.to_hash
    end
  end
end
