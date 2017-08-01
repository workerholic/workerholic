module Workerholic
  class StatsStorage

    def self.save_job(category, job)
      serialized_job_stats = JobSerializer.serialize(job)

      namespace = "workerholic:stats:#{category}:#{job.klass}"
      storage.push(namespace, serialized_job_stats)
    end

    def self.save_processes_memory_usage
      pid, size = `ps -p #{Process.pid} -o pid=,rss=`.scan(/\d+/).map(&:to_i)
      ppid, psize = `ps -p #{Process.ppid} -o pid=,rss=`.scan(/\d+/).map(&:to_i)

      @logger.info("PID: #{pid} -- Size: #{(size / 1024.to_f).round(2)} MB -- Parent: PID #{ppid} - Size: #{(psize / 1024.to_f).round(2)} MB")
    end

    class << self
      private

      def storage
        @storage ||= Storage::RedisWrapper.new
      end
    end
  end
end
