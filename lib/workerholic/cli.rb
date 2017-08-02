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

      Starter.options = options
      Starter.start
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
  end
end
