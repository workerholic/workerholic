require_relative 'workerholic'

class JobTest
  include Workerholic::Job

  def perform(str)
    puts "test_string to be passed to redis Yo. Plus that string #{str}"
  end
end

# Workerholic::Runner.run({ klass: JobTest, args: ["something"] })
JobTest.new.perform_async('hello world')
