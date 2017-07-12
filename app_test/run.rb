require_relative 'job_test'

1000.times do
  JobTest.new.perform_async('hello world')
end
