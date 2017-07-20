require_relative 'job_serializer'
require_relative 'statistics'

module Workerholic
  class JobProcessingError < StandardError; end

  class JobProcessor
    def initialize(serialized_job)
      @serialized_job = serialized_job
    end

    def process
      job_info = JobSerializer.deserialize(@serialized_job)
      job_class = job_info[:class]
      job_args = job_info[:arguments]
      job_stats = Workerholic::Statistics.new(job_info[:statistics])

      begin
        job_stats.started_at = Time.now
        finished_job = job_class.new.perform(*job_args)
        job_stats.completed_at = Time.now
        finished_job
      rescue Exception => e
        require 'pry'; binding.pry
        job_stats.errors.push(e)
        job_stats.retry_count += 1
        raise JobProcessingError, e.message
      end

      # Push job into some collection
    end
  end
end
