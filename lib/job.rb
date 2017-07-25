require_relative 'queue'
require_relative 'job_serializer'
require_relative 'statistics'
require_relative 'sorted_set'
require_relative 'job_wrapper'

module Workerholic
  module Job
    def self.included(base)
      base.extend(ClassMethods)
      base.job_options
    end

    module ClassMethods
      def job_options(params={})
        define_method(:specified_job_options) do
          {
            execute_at: params[:execute_at],
            queue_name: params[:queue_name] || 'workerholic:queue:main'
          }
        end
      end
    end

    def perform_async(*args)
      serialized_job, queue_name = prepare_job_for_enqueueing(args)

      Queue.new(queue_name).enqueue(serialized_job)
    end

    def perform_delayed(*args)
      delay_in_sec = verify_delay(args[0])
      serialized_job, queue_name = prepare_job_for_enqueueing(args)

      JobScheduler.new(set_name: queue_name).schedule(serialized_job, delay_in_sec)
    end

    private

    def verify_delay(delay_arg)
      raise ArgumentError, 'Delay argument has to be of Numeric type' unless delay_arg.is_a? Numeric

      delay_arg
    end

    def prepare_job_for_enqueueing(args)
      raise ArgumentError if self.method(:perform).arity != args.size

      job = JobWrapper.new(class: self.class, arguments: args)
      job.statistics.enqueued_at = Time.now.to_f

      [JobSerializer.serialize(job), specified_job_options[:queue_name]]
    end
  end
end
