module Workerholic
  class JobProcessor
    attr_reader :serialized_job

    def initialize(serialized_job)
      @serialized_job = serialized_job
      @logger = LogManager.new
    end

    def process
      job = JobSerializer.deserialize(serialized_job)

      begin
        job.statistics.started_at = Time.now.to_f
        job_result = job.perform
        job.statistics.completed_at = Time.now.to_f

        StatsStorage.save_job('completed_jobs', job)

        # @logger.info("Completed: your job from class #{job.klass} was completed on #{job.statistics.completed_at}.")
      rescue Exception => e
        job.statistics.errors.push([e.class, e.message])
        retry_job(job)

      end
      job_result
    end

    private

    def retry_job(job)
      if JobRetry.new(job: job).retry
        # @logger.error("Failed: your job from class #{job.class} was unsuccessful. Retrying in 10 secs...")
      else
        job.statistics.failed_on = Time.now.to_f
        StatsStorage.save_job('failed_jobs', job)

        # @logger.error("Failed: your job from class #{job.class} was unsuccessful.")
      end
    end
  end
end
