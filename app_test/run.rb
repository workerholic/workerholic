require_relative 'job_test'

module TestRunner
  def self.non_blocking(num_of_cycles)
    num_of_cycles.times do |n|
       JobTestFast.new.perform_async('NONBLOCKING', n)
    end
  end

  def self.blocking(num_of_cycles)
    num_of_cycles.times do |n|
      JobTestSlow.new.perform_async('BLOCKING', n)
    end
  end

  def self.thread_killer(num_of_cycles)
    num_of_cycles.times do |n|
      ThreadKiller.new.perform_async('Kill', n)
    end
  end

  def self.large_arg(num_of_cycles)
    arg = Array.new(10000, 'string')

    num_of_cycles.times do |n|
      LargeArg.new.perform_async(arg, n)
    end
  end

  def self.sort_array(num_of_cycles, array_size)
    unsorted_array = (0..array_size).to_a.shuffle

    num_of_cycles.times do |n|
      HeavyCalculation.new.perform_async(n, unsorted_array)
    end
  end

  def self.many_args(num_of_cycles)
    num_of_cycles.times do |n|
      ManyArgs.new.perform_async(n, [1, 2, 3], { key: 'value'}, :symb, 'string', 22, false)
    end
  end

  def self.calculate_primes(num_of_cycles)
    num_of_cycles.times do |n|
      GetPrimes.new.perform_async(n, 10)
    end
  end

  def self.enqueue_delayed(num_of_cycles)
    num_of_cycles.times do |n|
      FutureJob.new.perform_delayed(10, n)
    end
  end

  def self.enqueue_delayed_with_queue(num_of_cycles)
    num_of_cycles.times do |n|
      FutureJobWithQueue.new.perform_delayed(10, n)
    end
  end

  def self.failed_jobs(num_of_cycles)
    num_of_cycles.times do |n|
      FailedJob.new.perform_async(n)
    end
  end

  def self.failed_jobs_with_queue(num_of_cycles)
    num_of_cycles.times do |n|
      FailedJobWithQueue.new.perform_async(n)
    end
  end
end

pids = (1..5).to_a.map do
    fork do
      TestRunner.blocking(200)

      TestRunner.non_blocking(100)
      TestRunner.sort_array(100, 100)

      TestRunner.failed_jobs(1)
      TestRunner.failed_jobs_with_queue(1)

      TestRunner.enqueue_delayed(1)
      TestRunner.enqueue_delayed_with_queue(1)

      exit
    end
end

pids.each { |pid| Process.wait(pid) }
