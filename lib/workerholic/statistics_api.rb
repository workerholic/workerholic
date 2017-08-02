module Workerholic
  class StatsAPI
    CATEGORIES = %w(completed_jobs failed_jobs)

    def self.job_statistics(options={})
      if CATEGORIES.include? options[:category]
        job_classes = storage.keys_for_namespace(options[:category])

        if options[:count_only]
          self.parse_job_classes(job_classes)
        else
          self.parse_job_classes(job_classes, false)
        end
      else
        logger("Invalid arguments. Please specify one of the following categories:\n'completed_jobs', 'failed_jobs'.")
      end
    end

    def self.scheduled_jobs(options={})
      namespace = 'workerholic:scheduled_jobs'
      if options[:count_only]
        storage.sorted_set_members_count(namespace)
      else
        serialized_jobs = storage.sorted_set_members(namespace)
        parse_scheduled_jobs(serialized_jobs)
      end
    end

    def self.jobs_classes
      classes = storage.available_keys

      parsed_classes = classes.map do |klass|
        klass.split(':').last
      end.uniq

      parsed_classes.empty? ? 'No class data is available yet.' : parsed_classes
    end

    def self.queued_jobs
      fetched_queues = storage.fetch_queue_names
      parsed_queues = fetched_queues.map do |queue|
        [queue, storage.list_length(queue)]
      end

      parsed_queues
    end

    def self.process_stats
      namespace = 'workerholic:stats:memory:processes'
      storage.hash_get_all(namespace)
    end

    def self.active_proccesses
      namespace = 'workerholic:stats:memory:processes'
      storage.hash_keys(namespace)
    end

    private

    def self.storage
      @storage ||= Storage::RedisWrapper.new
    end

    def self.logger(message)
      @log ||= LogManager.new
    end

    def self.parse_scheduled_jobs(jobs)
      jobs.map do |job|
        deserialized_job = JobSerializer.deserialize_stats(job)
        self.convert_klass_to_string(deserialized_job)
      end
    end

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
      serialized_jobs = storage.peek_namespace(job_class)
      deserialized_stats = serialized_jobs.map do |serialized_job|
        deserialized_job = JobSerializer.deserialize_stats(serialized_job)
        self.convert_klass_to_string(deserialized_job)
      end

      deserialized_stats << deserialized_stats.size
    end

    def self.jobs_per_class(job_class)
      clean_class_name = job_class.split(':').last
      [clean_class_name, storage.list_length(job_class)]
    end

    def self.convert_klass_to_string(obj)
      obj[:klass] = obj[:klass].to_s
      obj[:wrapper] = obj[:wrapper].to_s
      obj
    end
  end
end
