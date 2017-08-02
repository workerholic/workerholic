class SimpleJobTest
  include Workerholic::Job
  job_options queue_name: TEST_QUEUE

  def perform(s)
    s
  end
end

class ComplexJobTest
  include Workerholic::Job
  job_options queue_name: TEST_QUEUE

  def perform(arg1, arg2, arg3)
    [arg1, arg2, arg3]
  end
end

class FirstJobBalancerTest
  include Workerholic::Job
  job_options queue_name: BALANCER_TEST_QUEUE

  def perform(str, n)
    str
  end
end

class SecondJobBalancerTest
  include Workerholic::Job
  job_options queue_name: ANOTHER_BALANCER_TEST_QUEUE

  def perform(str, n)
    str
  end
end

class DelayedJobTest
  include Workerholic::Job

  def perform(str)
    str
  end
end
