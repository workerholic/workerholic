module Workerholic
  class StatsAPI
    CATEGORIES = %w(completed_jobs failed_jobs)

    def self.job_statistics(options={})
      raise ArgumentError, "Please specify one of the following categories: 'completed_jobs', 'failed_jobs'" unless CATEGORIES.include? options[:category]

      job_classes = storage.get_keys_for_namespace("workerholic:stats:#{options[:category]}:*")

      if options[:count_only]
        self.parse_job_classes(job_classes)
      else
        self.parse_job_classes(job_classes, false)
      end
    end

    def self.job_statistics_history(category)
      raise ArgumentError, "Please specify one of the following categories: 'completed_jobs', 'failed_jobs'" unless CATEGORIES.include? category

      current_time = Time.now.to_i
      all_job_stats(category).reduce([]) do |result, job|
        completed_time = job.last.to_i
        index = (current_time - completed_time) / 10

        result[index] = result[index] ? result[index] + 1 : 1

        result
      end
    end

    def self.scheduled_jobs(options={})
      namespace = 'workerholic:scheduled_jobs'
      if options[:count_only]
        storage.sorted_set_size(namespace)
      else
        serialized_jobs = storage.sorted_set_all_members(namespace)
        parse_scheduled_jobs(serialized_jobs)
      end
    end

    def self.jobs_classes(historical)
      base_namespace = historical ? 'workerholic:stats:historical:' : 'workerholic:stats:'

      completed_classes = storage.get_keys_for_namespace( base_namespace + 'completed_jobs:*')
      failed_classes = storage.get_keys_for_namespace(base_namespace + 'failed_jobs:*')
      combined_classes = completed_classes + failed_classes

      combined_classes.map { |klass| klass.split(':').last }.uniq
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
      serialized_jobs = storage.sorted_set_all_members(job_class)
      deserialized_stats = serialized_jobs.map do |serialized_job|
        JobSerializer.deserialize_stats(serialized_job)
      end

      deserialized_stats << deserialized_stats.size
    end

    def self.jobs_per_class(job_class)
      clean_class_name = job_class.split(':').last
      [clean_class_name, storage.sorted_set_size(job_class)]
    end

    def self.convert_klass_to_string(obj)
      obj[:klass] = obj[:klass].to_s
      obj[:wrapper] = nil
      obj
    end

    def self.storage
      @storage ||= Storage::RedisWrapper.new
    end

    def self.logger(message)
      @log ||= LogManager.new
    end

    def self.all_job_stats(category)
      current_time = Time.now.to_i

      jobs_classes(false).map do |klass|
        storage.sorted_set_range_members("workerholic:stats:#{category}:#{klass}", current_time - 1000, current_time)
      end.flatten(1)
    end
  end
end
