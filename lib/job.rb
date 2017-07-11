require_relative 'queue'

module Workerholic

  module Job
    def perform_async(*args)
      Queue.enqueue(serialized(self.class, args))
    end

    def serialized(klass, args)
      job_obj = [klass, args]
      ::YAML.dump(job_obj)
    end
  end

end
