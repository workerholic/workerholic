require_relative 'queue'
require_relative 'job_serializer'
require_relative 'statistics'
require_relative 'sorted_set'

module Workerholic
  module Job
    def perform_async(*args)
      raise ArgumentError if self.method(:perform).arity != args.size

      job = {
        class: self.class,
        arguments: args,
        statistics: Statistics.new.to_hash
      }

      job[:statistics][:enqueued_at] = Time.now.to_f
      serialized_job = JobSerializer.serialize(job)

      if delayed_job?
        SortedSet.new.add(serialized_job)
      else
        Queue.new(queue_name).enqueue(serialized_job)
      end
    end

    def queue_name
      'default'
    end

    private

    def delayed_job?(*args)
      args.any? { |arg| arg == 'delayed_job' }
    end
  end
end
