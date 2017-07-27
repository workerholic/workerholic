module Workerholic
  class Statistics
    attr_reader :storage

    attr_accessor :enqueued_at,
                  :retry_count,
                  :errors,
                  :started_at,
                  :completed_at,
                  :failed_on,
                  :elapsed_time,
                  :job_class

    def initialize(options={})
      @job_class = options[:job_class]
      @enqueued_at = options[:enqueued_at]
      @errors = options[:errors] || []
      @started_at = options[:started_at]
      @completed_at = options[:completed_at]
      @elapsed_time = set_elapsed_time

      @storage = Storage::RedisWrapper.new
    end

    def to_hash
      {
        enqueued_at: enqueued_at,
        errors: errors,
        started_at: started_at,
        completed_at: completed_at,
        elapsed_time: elapsed_time,
        failed_on: failed_on,
        job_class: job_class
      }
    end

    def set_elapsed_time
      if completed_at && started_at
        @elapsed_time = format_elapsed_time(completed_at - started_at)
      else
        nil
      end
    end

    def format_elapsed_time(time)
      '%.10f' % time
    end

    def active_jobs
      namespace = 'workerholic:queue'
      [storage.get_jobs_stats(namespace), storage.keys_count(namespace)]
    end

    def completed_jobs
      namespace = 'workerholic:stats:completed_jobs'
      [storage.get_jobs_stats(namespace), storage.keys_count(namespace)]
    end

    def failed_jobs
      namespace = 'workerholic:stats:failed_jobs'
      [storage.get_jobs_stats(namespace), storage.keys_count(namespace)]
    end

    def processed_jobs
      namespace = 'workerholic:stats:processed_jobs'

      deserialized_stats = {}
      classes_hash = storage.get_jobs_stats(namespace)
      classes_hash.keys.each do |key|
        classes_hash[key].each do |serialized_stat|
          stat_hash = JobSerializer.deserialize_stats(serialized_stat)

          key = stat_hash[:job_class]
          if deserialized_stats[key]
            deserialized_stats[key] << stat_hash
          else
            deserialized_stats[key] = [stat_hash]
          end
        end
      end

      [deserialized_stats, storage.keys_count(namespace)]
    end

    def jobs_classes
      class_namespaces = ['workerholic:stats:active_jobs', 'workerholic:stats:processed_jobs']
      storage.get_job_classes(class_namespaces)
    end

    def queue_names
      queue_stats = []

      queues = storage.fetch_queue_names
      queues.each do |queue|
        queue_stats << [queue.name, queue.size]
      end
    end

    def add_stats(job, stats_queue)
      job_class = job.klass.to_s
      job.statistics.job_class = job_class

      serialized_job_stats = JobSerializer.serialize(job.statistics)

      # form a namespaced queue name like this: 'workerholic:stats:processed_jobs:our_class'
      composite_queue_name = stats_queue + ":#{job_class}"
      storage.push_stats(composite_queue_name, serialized_job_stats)
    end
  end
end
