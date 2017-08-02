$LOAD_PATH.unshift(__dir__ + '/../lib')
require 'workerholic'
require 'prime'

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
    sleep(0.5)
  end
end

class ThreadKiller
  include Workerholic::Job

  def perform(string, n)
    Thread.main.kill
  end
end

class LargeArg
  include Workerholic::Job

  def perform(arr, n)
  end
end

class ManyArgs
  include Workerholic::Job

  def perform(n, *args)
  end
end

# A CPU-blocking operation
class HeavyCalculation
  include Workerholic::Job

  def perform(n, arr)
    arr = bubble_sort(arr)
  end

  def bubble_sort(array)
    return array if array.size <= 1

    unsorted = true

    while unsorted do
      unsorted = false
      0.upto(array.size-2) do |i|
        if array[i] > array[i+1]
          array[i], array[i+1] = array[i+1], array[i]
          unsorted = true
        end
      end
    end

    array
  end
end

class GetPrimes
  include Workerholic::Job

  def perform(n, max)
    Prime.each(max) do |prime|
      prime
    end
  end
end

class FutureJob
  include Workerholic::Job

  def perform(n)
    n
  end
end

class FailedJob
  include Workerholic::Job

  def perform(n)
    raise Exception
  end
end
