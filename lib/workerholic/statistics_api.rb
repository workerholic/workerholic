module Workerholic
  class StatsAPI
    CATEGORIES = %w(completed_jobs failed_jobs)

    def self.job_statistics(options={})
      if CATEGORIES.include? options[:category]
        job_classes = self.storage.keys_for_namespace(options[:category])

        if options[:count_only]
          self.parse_job_classes(job_classes)
        else
          self.parse_job_classes(job_classes, false)
        end
      else
        self.logger("Invalid arguments. Please specify one of the following categories:\n'completed_jobs', 'failed_jobs'.")
      end
    end

    def self.jobs_classes
      classes = self.storage.available_keys

      parsed_classes = classes.map do |klass|
        klass.split(':').last
      end.uniq

      parsed_classes.empty? ? 'No class data is available yet.' : parsed_classes
    end

    def self.queue_names
      fetched_queues = self.storage.fetch_queue_names
      parsed_queues = fetched_queues.map do |queue|
        queue_data = [queue.name, queue.size]
        queues << queue_data
      end

      (parsed_queues.empty? ? 'No queues data is available yet.': parsed_queues)
    end

    private

    def self.parse_job_classes(job_classes, count_only = true)
      job_classes.map do |job_class|
        if count_only
          self.jobs_per_class(job_class)
        else
          self.get_jobs_for_class(job_class)
        end
      end
    end

    def self.get_jobs_for_class(job_class)
      serialized_jobs = self.storage.peek_namespace(job_class)
      deserialized_stats = serialized_jobs.map do |serialized_job|
        JobSerializer.deserialize_stats(serialized_job)
      end

      deserialized_stats << deserialized_stats.size
    end

    def self.jobs_per_class(job_class)
      clean_class_name = job_class.split(':').last
      [clean_class_name, self.storage.list_length(job_class)]
    end

    def self.storage
      Storage::RedisWrapper.new
    end

    def self.logger(message)
      LogManager.new.error(message)
    end
  end
end
