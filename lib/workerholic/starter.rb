module Workerholic
  class Starter
    def self.options=(opts={})
      @options = opts
    end

    def self.start
      apply_options
      load_app
      track_memory_usage_and_expire_job_stats
      launch
    end

    def self.kill_memory_tracker_thread
      @thread.kill
      StatsStorage.delete_memory_stats
    end

    private

    def self.options
      @options
    end

    def self.logger
      @logger ||= LogManager.new
    end

    def self.apply_options
      Workerholic.workers_count = options[:workers] if options[:workers]
      Workerholic.redis_connections_count = options[:redis_connections] if options[:redis_connections]
    end

    def self.load_app
      if options[:require]
        load_specified_file
      elsif File.exist?('./config/environment.rb')
        load_rails
      else
        display_app_load_info
      end
    end

    def self.load_rails
      require File.expand_path('./config/environment.rb')

      require 'workerholic/adapters/active_job_adapter'

      ActiveSupport.run_load_hooks(:before_eager_load, Rails.application)
      Rails.application.config.eager_load_namespaces.each(&:eager_load!)
    end

    def self.load_specified_file
      file_path = File.expand_path(options[:require])

      if File.exist?(file_path)
        require file_path
      else
        logger.info('The file you specified to load your application is not valid!')

        exit
      end
    end

    def self.display_app_load_info
      logger.info('If you are using a Rails app, make sure to navigate to your root directory before starting Workerholic!')
      logger.info('If you are not using a Rails app, you can load your app by using the option --require and specifying the file needing to be required in order to load your application.')

      exit
    end

    def self.track_memory_usage_and_expire_job_stats
      @thread = Thread.new do
        loop do
          sleep 5
          StatsStorage.save_processes_memory_usage
          StatsStorage.delete_expired_job_stats
        end
      end
    end

    def self.launch
      fork_processes if options[:processes] && options[:processes] > 1

      Workerholic.manager = Manager.new(auto_balance: options[:auto_balance])
      Workerholic.manager.start
    end

    def self.fork_processes
      (options[:processes] - 1).times do
        PIDS << fork do
          Workerholic.manager = Manager.new(auto_balance: options[:auto_balance])
          Workerholic.manager.start
        end
      end

      PIDS.freeze
    end
  end
end
