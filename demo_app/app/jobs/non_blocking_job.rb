class NonBlockingJob
  include Workerholic::Job
  job_options queue_name: 'non_blocking'

  def perform(arg)
    arg
  end
end
