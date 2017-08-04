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
      completed_classes = storage.get_keys_for_namespace('workerholic:stats:historical:completed_jobs:*')
      failed_classes = storage.get_keys_for_namespace('workerholic:stats:historical:failed_jobs:*')
      combined_classes = completed_classes + failed_classes

      parsed_classes = combined_classes.map do |klass|
        klass.split(':').last
      end.uniq

      parsed_classes.empty? ? [] : parsed_classes
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

    def self.history_for_period(options={})
      raise ArgumentError, 'Please provide a category namespace' unless options[:category]

      if options[:klass]
        namespace = "workerholic:stats:historical:#{options[:category]}:#{options[:klass]}"
      else
        namespace = "workerholic:stats:historical:#{options[:category]}"
      end

      period = options[:period] || 30
      date_ranges = self.get_past_dates(period)

      job_counts = storage.hash_get_multiple_elements(namespace, date_ranges)

      combine_ranges(job_counts: job_counts, date_ranges: date_ranges)
    end

    private

    def self.combine_ranges(options={})
      job_counts = options[:job_counts]
      job_counts.map!(&:to_i)

      {
        date_ranges: options[:date_ranges],
        job_counts: job_counts
      }
    end

    def self.get_past_dates(days)
      today = Time.now.utc.to_i - Time.now.utc.to_i % 86400

      (0..days).map { |day| today - day * 86400 }
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
