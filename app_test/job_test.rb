require_relative '../lib/job'

class JobTestFast
  include Workerholic::Job
  job_options queue_name: 'workerholic:queue:job_fast'

  def perform(str, num)
    str
  end
end

class JobTestSlow
  include Workerholic::Job
  job_options queue_name: 'workerholic:queue:job_slow'

  def perform(str, num)
    str
    sleep(0.1)
  end
end
