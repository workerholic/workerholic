module ActiveJob
  module QueueAdapters
    class WorkerholicAdapter
      def enqueue(job)
        job_data = job.serialize
        queue_name = "workerholic:queue:#{job_data['queue_name']}"

        job = JobWrapper.new
        job.instance_variable_set(:@queue_name, queue_name)

        # capture job class so it can be passed to `Base.execute` in `JobWrapper#perform`
        job.instance_variable_set(:@class, job_data['job_class'])

        job.perform_async(*job_data['arguments'])
      end

      class JobWrapper
        include Workerholic::Job

        def perform(job_data)
          Base.execute job_data
        end
      end
    end
  end
end
