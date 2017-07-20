require_relative 'queue'
require_relative 'job_serializer'
require_relative 'statistics'
require_relative 'sorted_set'

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
            delayed: params[:delayed],
            execute_at: params[:execute_at],
            queue_name: params[:queue_name] || 'workerholic:queue:main'
          }
        end
      end
    end

    def perform_async(*args)
      if self.method(:perform).arity != args.size || delayed_job?
        raise ArgumentError
      end

      queue_name = specified_job_options[:queue_name]

      job = {
        class: self.class,
        arguments: args,
        statistics: Statistics.new.to_hash
      }

      job[:statistics][:enqueued_at] = Time.now.to_f
      serialized_job = JobSerializer.serialize(job)

      Queue.new(queue_name).enqueue(serialized_job)
    end


    def perform_delayed(*args)
      if self.method(:perform).arity != args.size || !delayed_job?
        raise ArgumentError
      end

      queue_name = specified_job_options[:queue_name]

      job = {
        class: self.class,
        arguments: args,
        statistics: Statistics.new.to_hash
      }

      job[:statistics][:enqueued_at] = Time.now.to_f
      serialized_job = JobSerializer.serialize(job)

      JobScheduler.new(queue_name).schedule(serialized_job)
    end

    private

    def delayed_job?
      specified_job_options[:delayed] == true
    end
  end
end
