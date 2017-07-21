require 'redis'
require 'pry'

require_relative 'spec_helper'

require_relative '../lib/job_scheduler'
require_relative './helpers/job_tests.rb'

class SimpleDelayedJobTest
  include Workerholic::Job
  job_options queue_name: TEST_SCHEDULED_SORTED_SET

  def perform(n, s)
    s
  end
end

describe Workerholic::JobScheduler do
  let(:scheduler) { Workerholic::JobScheduler.new(set_name: TEST_SCHEDULED_SORTED_SET, queue_name: TEST_QUEUE) }
  let(:redis) { Redis.new }

  before { redis.del(TEST_SCHEDULED_SORTED_SET) }

  context 'with non-empty set' do
    let(:serialized_job) do
      job = Workerholic::JobWrapper.new(
        class: ComplexJobTest,
        arguments: ['test job', { a: 1, b: 2 }, [1, 2, 3]]
      )

      Workerholic::JobSerializer.serialize(job)
    end

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

      expect(scheduler.queue.empty?).to eq(false)
      expect(scheduler.queue.dequeue).to eq(serialized_job)
    end
  end

  context 'with delayed job option specified' do
    it 'adds delayed job to the scheduled sorted set' do
      SimpleDelayedJobTest.new.perform_delayed(2, 'test arg')

      expect(scheduler.sorted_set.empty?).to eq(false)
    end

    it 'raises an ArgumentError if perform_delayed first argument is not of Numeric type' do
      job = SimpleDelayedJobTest.new

      expect { job.perform_delayed("wrong type", 'test arg') }.to raise_error(ArgumentError)
    end
  end
end
