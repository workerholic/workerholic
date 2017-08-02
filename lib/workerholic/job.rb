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

      Queue.new(@queue_name || queue_name).enqueue(serialized_job)
    end

    def perform_delayed(*args)
      execution_time = Time.now.to_f + verify_delay(args)
      serialized_job = prepare_job_for_enqueueing(args).first

      sorted_set = SortedSet.new
      sorted_set.add(serialized_job, execution_time)
    end

    private

    def verify_delay(args)
      raise ArgumentError, 'Delay argument has to be of Numeric type' unless args[0].is_a? Numeric

      args.shift
    end

    def prepare_job_for_enqueueing(args)
      raise ArgumentError if self.method(:perform).arity != args.size

      job = JobWrapper.new(klass: @class || self.class, arguments: args, wrapper: self.class)

      job.statistics.enqueued_at = Time.now.to_f

      [JobSerializer.serialize(job), specified_job_options[:queue_name]]
    end
  end
end
