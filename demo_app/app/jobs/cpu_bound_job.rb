class CpuBoundJob
  include Workerholic::Job
  job_options queue_name: 'cpu_bound'

  def perform(arg)
    a, b = 0, 1

    while b < arg
      a, b = b, a + b
    end

    puts b
  end
end
