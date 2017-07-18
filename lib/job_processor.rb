require_relative 'job_serializer'

module Workerholic
  class JobProcessingError < StandardError; end

  class JobProcessor
    def initialize(serialized_job)
      @serialized_job = serialized_job
    end

    def process
      job_info = JobSerializer.deserialize(@serialized_job)
      job_class, job_args = job_info[:class], job_info[:arguments]

      begin
        job_class.new.perform(*job_args)
      rescue Exception => e
        raise JobProcessingError, e.message
      end
    end
  end
end
