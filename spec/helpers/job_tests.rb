require_relative '../../lib/job.rb'

class SimpleJobTest
  include Workerholic::Job

  def perform(s)
    s
  end

  def queue_name
    "test_queue"
  end
end

class ComplexJobTest
  include Workerholic::Job

  def perform(arg1, arg2, arg3)
    [arg1, arg2, arg3]
  end

  def queue_name
    "test_queue"
  end
end

