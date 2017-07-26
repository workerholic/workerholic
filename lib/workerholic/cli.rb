$LOAD_PATH << __dir__ + '/..'

require 'workerholic'

module Workerholic
  class CLI
    def self.run
      auto_balance = ARGV.any? { |arg| arg == '--auto-balance' }
      workers_count = ARGV.find { |arg| arg.match? /^--workers=\d+$/ }

      if workers_count
        workers_count = workers_count[/\d+/].to_i
        Workerholic.workers_count = workers_count
      end

      Manager.new.start
    end
  end
end


