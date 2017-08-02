module Workerholic
  class JobRetry
    attr_reader :job, :sorted_set, :stats_storage

    def initialize(options={})
      @job = options[:job]
      @sorted_set = options[:sorted_set] || SortedSet.new('workerholic:scheduled_jobs')
    end

    def retry
      return if job.retry_count >= 5

      increment_retry_count
      schedule_job_for_retry
      sorted_set.add(JobSerializer.serialize(job), job.execute_at)
    end

    private

    def increment_retry_count
      job.retry_count += 1
    end

    def schedule_job_for_retry
      job.execute_at = Time.now.to_f + 10 * job.retry_count
    end
  end
end
