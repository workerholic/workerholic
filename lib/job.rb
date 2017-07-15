require_relative 'queue'
require_relative 'job_serializer'

module Workerholic
  module Job
    # TODO raise error if the number of args passed to perform_async is not the same as perform

    def perform_async(*args)
      job = [self.class, args]
      serialized_job = JobSerializer.serialize(job)
      Queue.new(queue_name).enqueue(serialized_job)
    end

    def queue_name
      'default'
    end
  end
end
