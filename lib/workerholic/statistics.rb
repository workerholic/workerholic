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

# available namespaces
# 'workerholic:stats:completed_jobs'
# 'workerholic:stats:failed_jobs'
# 'workerholic:stats:processed_jobs'
# 'workerholic:stats:active_jobs'
# 'workerholic:stats:scheduled_jobs'

    def job_stats_for_namespace(namespace)
      deserialized_stats = {}
      processed_jobs_count = 0
      classes_hash = storage.get_jobs_stats(namespace)

      classes_hash.keys.each do |key|

        classes_hash[key].each do |serialized_stat|
          stat_hash = JobSerializer.deserialize_stats(serialized_stat)
          key = stat_hash[:job_class]

          if deserialized_stats[key]
            deserialized_stats[key] << stat_hash
            processed_jobs_count += 1
          else
            deserialized_stats[key] = [stat_hash]
            processed_jobs_count = 1
          end
        end
      end

      [deserialized_stats, processed_jobs_count]
    end


    def jobs_classes
      class_namespaces = ['workerholic:stats:active_jobs', 'workerholic:stats:processed_jobs']
      storage.get_job_classes(class_namespaces)
    end

    def queue_names(options={})
      persist_history = options[:history]
      namespace = 'workerholic:stats:historic:queues'
      queues = []

      fetched_queues = storage.fetch_queue_names
      fetched_queues.each do |queue|
        queue_data = [queue.name, queue.size]

        if persist_history
          append_history(namespace, queue_data)
        end

        queues << queue_data
      end

      (queues.empty? ? nil : queues) || 'No queues data is available yet.'
    end

    def append_history(namespace, value)
      serialized_data = JobSerializer.serialize(value)
      storage.push_stats(namespace, serialized_data)
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
