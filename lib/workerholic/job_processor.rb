module Workerholic
  class JobProcessor
    attr_reader :serialized_job, :stats_storage

    def initialize(serialized_job)
      @serialized_job = serialized_job
      @stats_storage = StatsStorage.new
      @logger = LogManager.new
    end

    def process
      job = JobSerializer.deserialize(serialized_job)

      begin
        job.statistics.started_at = Time.now.to_f
        job_result = job.perform
        job.statistics.completed_at = Time.now.to_f

        stats_storage.save_job('completed_jobs', job)

        # @logger.info("Completed: your job from class #{job.klass} was completed on #{job.statistics.completed_at}.")

        job_result
      rescue Exception => e
        job.statistics.errors.push([e.class, e.message])
        retry_job(job)

        # @logger.error("Failed: your job from class #{job.class} was unsuccessful. Retrying in 10 seconds.")
      end

      job_result
    end

    private

    def retry_job(job)
      limit_reached = JobRetry.new(job: job)
      if limit_reached
        job.statistics.failed_on = Time.now.to_f
      end
    end
  end
end
