require 'redis'
require 'pry'

require_relative 'spec_helper'

require_relative '../lib/job_scheduler'
require_relative './helpers/job_tests.rb'

describe Workerholic::JobScheduler do
  context 'with non-empty set' do
    let(:scheduler) { Workerholic::JobScheduler.new(set_name: 'workerholic:test:scheduled_jobs') }
    let(:redis) { Redis.new }
    let(:serialized_job) {  Workerholic::JobSerializer.serialize({
                         class: ComplexJobTest,
                         arguments: ['test job', { a: 1, b: 2 }, [1, 2, 3]],
                         statistics: Workerholic::Statistics.new.to_hash
                       })
    }

    after { redis.del('workerholic:test:scheduled_jobs') }

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

    xit 'checks the sorted set every N seconds' do
      
    end
  end
end
