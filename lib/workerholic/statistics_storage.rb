module Workerholic
  class StatsStorage
    def self.save_job(category, job)
      job_hash = job.to_hash
      serialized_job_stats = JobSerializer.serialize(job_hash)

      namespace = "workerholic:stats:#{category}:#{job.klass}"
      storage.add_to_set(namespace, job.statistics.completed_at, serialized_job_stats)
    end

    def self.update_historical_stats(category, klass)
      current_day_secs = Time.now.utc.to_i - (Time.now.utc.to_i % 86400)
      namespace = "workerholic:stats:historical:#{category}"
      namespace_with_class = "workerholic:stats:historical:#{category}:#{klass}"

      storage.hash_increment_field(namespace, current_day_secs, 1)
      storage.hash_increment_field(namespace_with_class, current_day_secs, 1)
    end

    def self.save_processes_memory_usage
      PIDS.each do |pid|
        size = `ps -p #{Process.pid} -o pid=,rss=`.scan(/\d+/).last
        storage.hash_set('workerholic:stats:memory:processes', pid, size)
      end
    end

    def self.delete_memory_stats
      storage.delete('workerholic:stats:memory:processes')
    end

    def self.delete_expired_job_stats
      max_time = Time.now.to_i - 1001
      StatsAPI.jobs_classes(false).each do |klass|
        storage.remove_range_from_set("workerholic:stats:completed_jobs:#{klass}", 0, max_time)
        storage.remove_range_from_set("workerholic:stats:failed_jobs:#{klass}", 0, max_time)
      end
    end

    class << self
      private

      def storage
        @storage ||= Storage::RedisWrapper.new
      end
    end
  end
end
