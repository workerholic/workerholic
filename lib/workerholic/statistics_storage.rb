module Workerholic
  class StatsStorage

    def self.save_job(category, job)
      serialized_job_stats = JobSerializer.serialize(job)

      namespace = "workerholic:stats:#{category}:#{job.klass}"
      storage.push(namespace, serialized_job_stats)
    end

    class << self
      private

      def storage
        @storage ||= Storage::RedisWrapper.new
      end
    end
  end
end
