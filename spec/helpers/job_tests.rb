require_relative '../../lib/job.rb'

class SimpleJobTest
  include Workerholic::Job
  job_options queue_name: 'workerholic:test:queue'

  def perform(s)
    s
  end
end

class ComplexJobTest
  include Workerholic::Job
  job_options queue_name: 'workerholic:test:queue'


  def perform(arg1, arg2, arg3)
    [arg1, arg2, arg3]
  end
end

