class IoBoundJob
  include Workerholic::Job
  job_options queue_name: 'io_bound'

  def perform
    puts HTTP.get('https://jsonplaceholder.typicode.com/posts/1').parse
  end
end
