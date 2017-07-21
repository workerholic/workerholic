require_relative 'job_serializer'
require_relative 'statistics'
require_relative 'job_retry'
require_relative 'log_manager'

module Workerholic
  class JobProcessor
    def initialize(serialized_job)
      @serialized_job = serialized_job
    end

    def process
      job = JobSerializer.deserialize(@serialized_job)

      begin
        job.statistics.started_at = Time.now.to_f
        job_result = job.perform
        job.statistics.completed_at = Time.now.to_f

        LogManager.new('info').log("Your job from class #{job.klass} was completed on #{job.statistics.completed_at}.")

        job_result
      rescue Exception => e
        job.statistics.errors.push([e.class, e.message])
        JobRetry.new(job: job)

        LogManager.new('error').log("Your job from class #{job.klass} was unsuccessful. Retrying in 10 seconds.")
      end

      # Push job into some collection
    end
  end
end
