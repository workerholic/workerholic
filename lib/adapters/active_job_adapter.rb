module ActiveJob
  module QueueAdapters
    class WorkerholicAdapter
      def enqueue(job)
        JobWrapper.new.perform_async job.serialize
      end

      class JobWrapper
        include Workerholic::Job

        def perform(job_data)
          Base.execute job_data
        end
      end
    end
  end

  autoload :WorkerholicAdapter
end
