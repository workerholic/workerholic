module Workerholic
  class StatsStorage

    def self.save_job(category, job)
      serialized_job_stats = JobSerializer.serialize(job)

      namespace = "workerholic:stats:#{category}:#{job.klass}"
      self.storage.push(namespace, serialized_job_stats)
    end

    private

    def self.storage
      Storage::RedisWrapper.new
    end
  end
end
