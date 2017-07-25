module ActiveJob
  module QueueAdapters
    class WorkerholicAdapter
      def enqueue(job)
        job_data = job.serialize

        JobWrapper.new.perform_async(
          class: job_data[:job_class],
          arguments: job_data[:arguments]
        )
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
