$LOAD_PATH << __dir__

require 'workerholic'

auto_balance = ARGV.any? { |arg| arg == '--auto-balance' }
Workerholic::Manager.new(auto_balance: auto_balance).start
