require 'yaml'
require 'pry-byebug'

require_relative 'job'
require_relative 'worker'
require_relative 'manager'

require_relative '../app_test/job_test'

Workerholic::Manager.blpoll
module Workerholic
end
