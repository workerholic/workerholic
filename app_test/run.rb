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

  def self.generate_array(num_of_cycles, array_size)
    num_of_cycles.times do
      HeavyCalculation.new.perform_async(array_size)
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

  def self.multiple_processes(num_of_proc, jobs)
    pids = (1..num_of_proc).to_a.map do
      fork do
        jobs.each do |job|
          TestRunner.send(:job[0], job[1..-1])
        end

        exit
      end
    end

    pids.each { |pid| Process.wait(pid) }
  end

  def self.fibonacci_cruncher(num_of_cycles)
    num_of_cycles.times do |n|
      FibCruncher.new.perform_async(1_000_000_000)
    end
  end
end


TestRunner.non_blocking(10)
TestRunner.blocking(10)
#TestRunner.generate_array(200, 1_000_000)
