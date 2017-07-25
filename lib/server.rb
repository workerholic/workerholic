$LOAD_PATH << __dir__

require 'workerholic'

auto_balance = ARGV.any? { |arg| arg == '--auto-balance' }
workers_count = ARGV.find { |arg| arg.match? /^--workers=\d+$/ }

if workers_count
  workers_count = workers_count[/\d+/].to_i
  Workerholic.workers_count = workers_count
end

Workerholic::Manager.new(auto_balance: auto_balance).start
