require_relative 'job_serializer'

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
        # require 'pry'; binding.pry
        finished_job = job_class.new.perform(*job_args)
        job_stats[:completed_at] = Time.now
        finished_job
      rescue Exception => e
        # job_stats[:errors].push(e)
        raise JobProcessingError, e.message
      end

      # Push job into some collection
      # def record
      #
      # end
    end
  end
end
