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
  job_options queue_name: FIRST_BALANCER_TEST_QUEUE

  def perform(str, n)
    str
  end
end

class SecondJobBalancerTest
  include Workerholic::Job
  job_options queue_name: SECOND_BALANCER_TEST_QUEUE

  def perform(str, n)
    str
  end
end

class ThirdJobBalancerTest
  include Workerholic::Job
  job_options queue_name: THIRD_BALANCER_TEST_QUEUE

  def perform(str, n)
    str
  end
end

class FourthJobBalancerTest
  include Workerholic::Job
  job_options queue_name: FOURTH_BALANCER_TEST_QUEUE

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
