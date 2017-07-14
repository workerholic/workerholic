require_relative 'job_serializer'

module Workerholic
  class JobProcessor
    def initialize(serialized_job)
      @serialized_job = serialized_job
    end

    def process
      components = JobSerializer.deserialize(@serialized_job)
      job_class, job_args = components.first, components.last
      job_class.new.perform(*job_args)
    end
  end
end
