require_relative 'job_serializer'
require_relative 'statistics'
require_relative 'job_retry'

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
        job_stats[:started_at] = Time.now.to_f
        finished_job = job_class.new.perform(*job_args)
        completed_time = Time.now.to_f
        job_stats[:completed_at] = completed_time
        LogManager.new('info').log("Your job from class #{job_class} was completed on #{completed_time}.")
        finished_job
      rescue Exception => e
        job_stats.errors.push([e.class, e.message])
        LogManager.new('error').log("Your job from class #{job_class} was unsuccessful. Retrying in 30 seconds.")
        JobRetry.new(job: job)
      end

      # Push job into some collection
    end
  end
end
