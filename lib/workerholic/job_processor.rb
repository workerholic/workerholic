module Workerholic
  class JobProcessor
    def initialize(serialized_job)
      @serialized_job = serialized_job
      @logger = LogManager.new
    end

    def process
      job = JobSerializer.deserialize(@serialized_job)

      begin
        job.statistics.started_at = Time.now.to_f
        job_result = job.perform
        job.statistics.completed_at = Time.now.to_f
        job.statistics.set_elapsed_time

        #@logger.log('info', "Completed: your job from class #{job.klass} was completed on #{job.statistics.completed_at}. It took #{job.statistics.elapsed_time} from start to finish.")

        job_result
      rescue Exception => e
        job.statistics.errors.push([e.class, e.message])
        retry_job(job)

        #@logger.log('error', "Failed: your job from class #{job.klass} was unsuccessful. Retrying in 10 seconds.")
      end

      add_job_stats_to_storage(job)
      job_result
    end

    private

    def retry_job(job)
      limit_reached = JobRetry.new(job: job)
      if limit_reached
        job.statistics.failed_on = Time.now.to_f
      end
    end

    def add_job_stats_to_storage(job)
      serialized_job_stats = JobSerializer.serialize(job.statistics.to_hash)
      Queue.new('workerholic:stats').enqueue(serialized_job_stats)
    end
  end
end
