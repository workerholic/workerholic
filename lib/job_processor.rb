require_relative 'job_serializer'
require_relative 'job_retry'
require_relative 'statistics'

module Workerholic
  class JobProcessingError < StandardError; end

  class JobProcessor
    def initialize(serialized_job)
      @serialized_job = serialized_job
    end

    def process
      job = JobSerializer.deserialize(@serialized_job)

      job_class = job[:class]
      job_args = job[:arguments]
      job_stats = Workerholic::Statistics.new(job[:statistics])

      begin
        job_stats.started_at = Time.now.to_f
        job_result = job_class.new.perform(*job_args)
        job_stats.completed_at = Time.now.to_f

        job_result
      rescue Exception => e
        job_stats.errors.push([e.class, e.message])
        JobRetry.new(job: job)
      end

      # Push job into some collection
    end
  end
end
