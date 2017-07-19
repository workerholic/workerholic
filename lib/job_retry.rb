require_relative 'sorted_set'
require_relative 'job_serializer'

module Workerholic
  class JobRetry
    attr_reader :job, :sorted_set

    def initialize(options={})
      @job = options[:job]
      @sorted_set = options[:sorted_set] || SortedSet.new('workerholic:scheduled_jobs')

      self.retry
    end

    protected

    def retry
      if job[:retries] < 5
        increment_number_of_retries
        schedule_job_for_retry
        # sorted_set.add(JobSerializer.serialize(job), job[:execute_at])
      end
    end

    private

    def increment_number_of_retries
      job[:retries] += 1
    end

    def schedule_job_for_retry
      job[:execute_at] = Time.now.to_f + 10 * job[:retries]
    end
  end
end
