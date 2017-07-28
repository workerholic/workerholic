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

    def job_stats_for_namespace(namespace)
      namespace = 'workerholic:stats:' + namespace
      deserialized_stats = {}
      stat_items_count = 0
      classes_hash = storage.get_stats(namespace)

      classes_hash.keys.each do |key|

        classes_hash[key].each do |serialized_stat|
          stat_hash = JobSerializer.deserialize_stats(serialized_stat)
          key = stat_hash[:job_class]

          if deserialized_stats[key]
            deserialized_stats[key] << stat_hash
            stat_items_count += 1
          else
            deserialized_stats[key] = [stat_hash]
            stat_items_count = 1
          end
        end
      end

      [deserialized_stats, stat_items_count]
    end

    def jobs_classes
      class_namespaces = ['workerholic:stats:completed_jobs', 'workerholic:stats:failed_jobs']
      classes = storage.get_classes(class_namespaces)
      (classes.empty? ? nil : classes) || 'No class data is available yet.'
    end

    def queue_names(options={})
      persist_history = options[:history]
      queues = []

      fetched_queues = storage.fetch_queue_names
      fetched_queues.each do |queue|
        queue_data = [queue.name, queue.size]

        if persist_history == true
          append_history('queues', queue_data)
        end

        queues << queue_data
      end

      (queues.empty? ? nil : queues) || 'No queues data is available yet.'
    end

    def append_history(namespace, value)
      namespace = 'workerholic:stats:historic:' + namespace
      serialized_data = JobSerializer.serialize(value)
      storage.push_stats(namespace, serialized_data)
    end

    def add_stats(job, namespace)
      job_class = job.klass.to_s
      job.statistics.job_class = job_class

      serialized_job_stats = JobSerializer.serialize(job.statistics)

      # form a namespaced queue name like this: 'workerholic:stats:processed_jobs:our_class'
      namespace = 'workerholic:stats:' + namespace + ":#{job_class}"
      storage.push(namespace, serialized_job_stats)
    end
  end
end
