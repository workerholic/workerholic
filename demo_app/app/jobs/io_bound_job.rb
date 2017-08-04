class IoBoundJob
  include Workerholic::Job
  job_options queue_name: 'io_bound'

  def perform
    puts HTTP.get('https://api.github.com/repos/workerholic/workerholic').parse
  end
end
