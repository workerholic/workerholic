module Workerholic
  class StatsAPI
    # available categories
    # completed_jobs
    # failed_jobs

    def self.job_statistics(category)
      stats = self.storage.keys_for_namespace("workerholic:stats:#{category}")
      self.parse_job_classes(stats)
    end

    def self.jobs_classes
      class_namespaces = ['workerholic:stats:completed_jobs', 'workerholic:stats:failed_jobs']
      classes = self.storage.peek_namespaces(class_namespaces)

      parsed_classes = classes.map do |klass|
        klass.split(':').last
      end.uniq

      parsed_classes.empty? ? 'No class data is available yet.' : parsed_classes
    end

    def self.queue_names
      queues = []

      fetched_queues = self.storage.fetch_queue_names
      fetched_queues.each do |queue|
        queue_data = [queue.name, queue.size]
        queues << queue_data
      end

      (queues.empty? ? 'No queues data is available yet.': queues)
    end

    private

    def self.parse_job_classes(job_classes)
      job_classes.map do |job_class|
        self.get_jobs_for_class(job_class)
      end
    end

    def self.get_jobs_for_class(job_class)
      serialized_jobs = self.storage.peek_namespace(job_class)
      deserialized_stats = serialized_jobs.map do |serialized_job|
        JobSerializer.deserialize_stats(serialized_job)
      end

      deserialized_stats
    end

    def self.storage
      storage ||= Storage::RedisWrapper.new
    end
  end
end
