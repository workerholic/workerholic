require_relative 'job_test'

20.times do |n|
  JobTestFast.new.perform_async('NON BLOCKING', n)
  JobTestSlow.new.perform_async('BLOCKING', n)
end
