require_relative 'job_serializer'
require_relative 'statistics'
require_relative 'job_retry'
require_relative 'log_manager'

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

        LogManager.new('info').log("Your job from class #{job_class} was completed on #{job_stats.completed_at}.")

        job_result
      rescue Exception => e
        job_stats.errors.push([e.class, e.message])
        JobRetry.new(job: job)

        LogManager.new('error').log("Your job from class #{job_class} was unsuccessful. Retrying in 10 seconds.")
      end

      # Push job into some collection
    end
  end
end
