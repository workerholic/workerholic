module Workerholic
  class Statistics
    @@storage = nil

    attr_accessor :enqueued_at,
                  :retry_count,
                  :errors,
                  :started_at,
                  :completed_at,
                  :failed_on,
                  :job_class

    def initialize(options={})
      @job_class = options[:job_class]
      @enqueued_at = options[:enqueued_at]
      @errors = options[:errors] || []
      @started_at = options[:started_at]
      @completed_at = options[:completed_at]
      @@storage = Storage::RedisWrapper.new
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

    def elapsed_time
      if completed_at && started_at
        format_elapsed_time(completed_at - started_at)
      end
    end

    def format_elapsed_time(time)
      '%.10f' % time
    end

    # available categories
    # completed_jobs
    # failed_jobs

    def self.add_stat(category, job)
      job_class = job.klass.to_s
      job.statistics.job_class = job_class

      serialized_job_stats = JobSerializer.serialize(job.statistics)

      namespace = "workerholic:stats:#{category}:#{job_class}"
      @@storage.push(namespace, serialized_job_stats)
    end

    def self.job_statistics(category)
      stats = @@storage.get_stats("workerholic:stats:#{category}")
      stats.map do |job|
        job.last.map do |serialized_stat|
          JobSerializer.deserialize_stats(serialized_stat)
        end

        job << job.last.size
      end
    end

    def self.jobs_classes
      class_namespaces = ['workerholic:stats:completed_jobs', 'workerholic:stats:failed_jobs']
      classes = @@storage.get_classes(class_namespaces)
      (classes.empty? ? nil : classes) || 'No class data is available yet.'
    end

    def self.queue_names
      queues = []

      fetched_queues = @@storage.fetch_queue_names
      fetched_queues.each do |queue|
        queue_data = [queue.name, queue.size]
        queues << queue_data
      end

      (queues.empty? ? nil : queues) || 'No queues data is available yet.'
    end
  end
end
