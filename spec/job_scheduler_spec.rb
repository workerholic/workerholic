require 'redis'

require_relative 'spec_helper'

require_relative '../lib/job_scheduler'
require_relative './helpers/job_tests.rb'

def expect_during(duration_in_secs, target)
  timeout = Time.now.to_f + duration_in_secs

  while Time.now.to_f <= timeout
    result = yield
    return if result == target

    sleep(0.001)
  end

  expect(result).to eq(target)
end

class SimpleDelayedJobTest
  include Workerholic::Job
  job_options queue_name: TEST_SCHEDULED_SORTED_SET

  def perform(n, s)
    s
  end
end

describe Workerholic::JobScheduler do
  let(:scheduler) { Workerholic::JobScheduler.new({ set_name: TEST_SCHEDULED_SORTED_SET }) }
  let(:redis) { Redis.new }

  context 'with non-empty set' do
    let(:serialized_job) {  Workerholic::JobSerializer.serialize({
        class: ComplexJobTest,
        arguments: ['test job', { a: 1, b: 2 }, [1, 2, 3]],
        statistics: Workerholic::Statistics.new.to_hash
      })
    }

    after { redis.del(TEST_SCHEDULED_SORTED_SET) }

    it 'checks the time for scheduled job inside sorted set' do
      score = Time.now.to_f
      scheduler.schedule(serialized_job, score)

      expect(scheduler.job_due?).to eq(true)
    end

    it 'fetches a job from a sorted set' do
      score = Time.now.to_f
      scheduler.schedule(serialized_job, score)
      scheduler.enqueue_due_jobs

      expect(scheduler.sorted_set.empty?).to eq(true)
    end

    it 'enqueues due job to the main queue' do
      score = Time.now.to_f
      scheduler.schedule(serialized_job, score)
      scheduler.enqueue_due_jobs

      queue = scheduler.queue

      expect(queue.empty?).to eq(false)
      expect(queue.dequeue).to eq(serialized_job)
    end
  end

  context 'with delayed job option specified' do
    after { redis.del(TEST_SCHEDULED_SORTED_SET) }

    it 'adds delayed job to the scheduled sorted set' do
      SimpleDelayedJobTest.new.perform_delayed(2, 'test arg')

      expect_during(1, false) { scheduler.sorted_set.empty? }
    end

    it 'raises an ArgumentError if perform_delayed first argument is not of Numeric type' do
      job = SimpleDelayedJobTest.new

      expect { job.perform_delayed("wrong type", 'test arg') }.to raise_error(ArgumentError)
    end
  end
end
