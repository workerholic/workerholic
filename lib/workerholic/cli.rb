$LOAD_PATH << __dir__ + '/..'

require 'workerholic'
require 'optparse'
require 'singleton'

module Workerholic
  PROCESSES_IDS = [Process.pid]

  class CLI
    include Singleton

    attr_reader :logger, :options

    def initialize
      @logger = LogManager.new
    end

    def run
      parse_options
      set_options

      load_app

      # Manager.new(auto_balance: options[:auto_balance]).start
      start
    end

    private

    def parse_options
      @options = {}

      OptionParser.new do |opts|
        opts.banner = 'Usage: workerholic [options]'

        opts.on '-a', '--auto-balance', 'auto-balance workers based on number of jobs in each queue' do
          options[:auto_balance] = true
        end

        opts.on '-w', '--workers INT', 'number of concurrent workers' do |count|
          count = count.to_i

          if count < 1
            logger.error('Invalid number of workers. Please specify a valid number of workers.')
            exit
          else
            options[:workers] = count.to_i
          end
        end

        opts.on '-r', '--require PATH', 'file to be required to load your application' do |file|
          options[:require] = file
        end

        opts.on '-h', '--help', 'show help' do
          logger.info(opts)
          exit
        end

        opts.on '-p', '--processes INT', 'number of processes to start in parallel' do |count|
          count = count.to_i

          if count < 1
            logger.error('Invalid number of processes. Please specify a valid number of processes.')
            exit
          else
            options[:processes] = count.to_i
          end
        end
      end.parse!
    end

    def set_options
      Workerholic.workers_count = options[:workers] if options[:workers]
    end

    def load_app
      if File.exist?('./config/environment.rb')
        require File.expand_path('./config/environment.rb')

        require 'workerholic/adapters/active_job_adapter'

        ActiveSupport.run_load_hooks(:before_eager_load, Rails.application)
        Rails.application.config.eager_load_namespaces.each(&:eager_load!)
      elsif options[:require]
        file_path = File.expand_path(options[:require])

        if File.exist?(file_path)
          require file_path
        else
          logger.info('The file you specified to load your application is not valid!')

          exit
        end
      else
        logger.info('If you are using a Rails app, make sure to navigate to your root directory before starting Workerholic!')
        logger.info('If you are not using a Rails app, you can load your app by using the option --require and specifying the file needing to be required in order to load your application.')

        exit
      end
    end

    def start
      if options[:processes] && options[:processes] > 1
        options[:processes].times do
          PROCESSES_IDS << fork do
            Manager.new(auto_balance: options[:auto_balance]).start
          end
        end

        sleep
      else
        Manager.new(auto_balance: options[:auto_balance]).start
      end
    rescue SystemExit, Interrupt
      exit
    end
  end
end
