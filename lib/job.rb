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

      serialized_job = JobSerializer.serialize(job)

      Queue.new(queue_name).enqueue(serialized_job)
    end

    def queue_name
      'workerholic:main'
    end
  end
end
