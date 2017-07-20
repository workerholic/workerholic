require_relative 'job_serializer'
require_relative 'log_manager'

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
      job_stats = job_info[:statistics]

      begin
        job_stats[:started_at] = Time.now
        finished_job = job_class.new.perform(*job_args)
        completed_time = Time.now
        job_stats[:completed_at] = completed_time
        LogManager.new('info').log("Your job from class #{job_class} was completed on #{completed_time}.")
        finished_job
      rescue Exception => e
        job_stats[:errors].push(e)
        job_stats[:retry_count] += 1
        raise JobProcessingError, e.message
      end

      # Push job into some collection
    end
  end
end
