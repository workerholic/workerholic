require 'yaml'
require 'pry-byebug'

require_relative 'job'
require_relative 'worker'
require_relative 'manager'

require_relative '../app_test/job_test'

auto_balance = ARGV.any? { |arg| arg == '--auto-balance' }
Workerholic::Manager.new(auto_balance: auto_balance).start
