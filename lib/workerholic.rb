require 'yaml'
require 'pry-byebug'

require_relative 'job'
require_relative 'worker'
require_relative 'manager'

require_relative '../app_test/job_test'

Workerholic::Manager.new.start

loop do
  sleep 5
end
