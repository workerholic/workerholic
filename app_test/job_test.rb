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
    sleep(0.5)
    puts "#{num} - #{str}"
  end
end

class ThreadKiller
  include Workerholic::Job

  def perform(string, n)
    puts "#{n}. #{string}"
    Thread.main.kill
  end
end

class LargeArg
  include Workerholic::Job

  def perform(arr, n)
    puts n
  end
end

class ManyArgs
  include Workerholic::Job

  def perform(n, *args)
    puts "#{n}: #{args}"
  end
end

# A CPU-blocking operation
class HeavyCalculation
  include Workerholic::Job

  def perform(n, arr)
    arr = bubble_sort(arr)
    puts "#{n}: #{arr[0..9]}"
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
    puts n
  end
end
