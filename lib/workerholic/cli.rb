$LOAD_PATH << __dir__ + '/..'

require 'workerholic'
require 'optparse'
require 'singleton'

module Workerholic
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

      Manager.new(auto_balance: options[:auto_balance]).start
    end

    def parse_options
      @options = {}

      OptionParser.new do |opts|
        opts.banner = 'Usage: workerholic [options]'

        opts.on '-a', '--auto-balance', 'auto-balance workers based on number of jobs in each queue' do
          options[:auto_balance] = true
        end

        opts.on '-w', '--workers INT', 'number of concurrent workers' do |count|
          options[:workers] = count.to_i
        end

        opts.on '-r', '--require PATH', 'file to be required to load your application' do |file|
          options[:require] = file
        end

        opts.on '-h', '--help', 'show help' do
          logger.info(opts)
          exit
        end
      end.parse!
    end

    def set_options
      Workerholic.workers_count = options[:workers_count] if options[:workers_count]
    end

    def load_app
      if File.exist?('./config/environment.rb')
        require File.expand_path('./config/environment.rb')
        require 'workerholic/adapters/active_job_adapter'
      elsif options[:require]
        if File.exist?(options[:require])
          require File.expand_path(options[:require])
        else
          log.info('The file you specified to load your application is not valid!')
          exit
        end
      else
        logger.info('If you are using a Rails app, make sure to navigate to your root directory before starting Workerholic!')
        logger.info('If you are not using a Rails app, you can load your app by using the option --require and specifying the file needing to be required in order to load your application.')

        exit
      end
    end
  end
end
