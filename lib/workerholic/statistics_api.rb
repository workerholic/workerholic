module Workerholic
  class StatsAPI
    attr_reader :storage

    def initialize
      @storage = Storage::RedisWrapper.new
    end

    # available categories
    # completed_jobs
    # failed_jobs

    def job_statistics(category)
      stats = storage.keys_for_namespace("workerholic:stats:#{category}")
      parse_job_classes(stats)
    end

    def jobs_classes
      class_namespaces = ['workerholic:stats:completed_jobs', 'workerholic:stats:failed_jobs']
      classes = storage.peek_namespaces(class_namespaces)

      parsed_classes = classes.map do |klass|
        klass.split(':').last
      end.uniq

      (parsed_classes.empty? ? nil : parsed_classes) || 'No class data is available yet.'
    end

    def queue_names
      queues = []

      fetched_queues = storage.fetch_queue_names
      fetched_queues.each do |queue|
        queue_data = [queue.name, queue.size]
        queues << queue_data
      end

      (queues.empty? ? nil : queues) || 'No queues data is available yet.'
    end

    private

    def parse_job_classes(job_classes)
      job_classes.map do |job_class|
        get_jobs_for_class(job_class)
      end
    end

    def get_jobs_for_class(job_class)
      serialized_jobs = storage.peek_namespace(job_class)
      deserialized_stats = serialized_jobs.map do |serialized_job|
        JobSerializer.deserialize_stats(serialized_job)
      end

      deserialized_stats
    end
  end
end
