module Workerholic
  class StatsAPI
    CATEGORIES = %w(completed_jobs failed_jobs)

    def self.job_statistics(options={})
      if CATEGORIES.include? options[:category]
        job_classes = storage.get_keys_for_namespace('workerholic:stats:' + options[:category] + ':*')

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
      classes = storage.get_keys_for_namespace('workerholic:stats:*')

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

    def self.history_for_period(category, period = 30)
      namespace = "workerholic:stats:historical:#{category}"

      start_time = self.convert_to_time_ago(period)
      end_time = Time.now.to_i
      # with scores
      jobs_range = storage.members_in_range(namespace, start_time, end_time)

      jobs_range.map do |range|
        jobs_count, time_int = range
        [jobs_count, self.time_to_date(time_int)]
      end
    end

    def self.history_for_class(category, klass, period = 30)
      namespace = "workerholic:stats:historical:#{category}:#{klass}"

      start_time = self.convert_to_time_ago(period)
      end_time = Time.now.to_i
      # with scores
      classes_range = storage.members_in_range(namespace, start_time, end_time)

      classes_range.map do |range|
        classes_count, time_int = range
        date = self.convert_time_to_date(time_int)
        [classes_count, date]
      end
    end

    private

    def self.convert_to_time_ago(days)
      Time.now.to_i - 86400 * 30 - Time.now.to_i % 86400
    end

    def self.convert_time_to_date(time_int)
      Time.at time_int
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
      serialized_jobs = storage.get_all_elements_from_list(job_class)
      deserialized_stats = serialized_jobs.map do |serialized_job|
        JobSerializer.deserialize_stats(serialized_job)
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

    def self.storage
      @storage ||= Storage::RedisWrapper.new
    end

    def self.logger(message)
      @log ||= LogManager.new
    end
  end
end
