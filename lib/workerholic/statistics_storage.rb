module Workerholic
  class StatsStorage
    attr_reader :storage

    def initialize
      @storage = Storage::RedisWrapper.new
    end

    def save_job(category, job)
      serialized_job_stats = JobSerializer.serialize(job)

      namespace = "workerholic:stats:#{category}:#{job.klass}"
      storage.push(namespace, serialized_job_stats)
    end
  end
end
