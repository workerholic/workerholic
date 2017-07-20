require 'redis'
require 'pry'

require_relative 'spec_helper'

require_relative '../lib/job_scheduler'
require_relative './helpers/job_tests.rb'

def expect_during(duration_in_sec, target)
  while yield != target
    sleep(0.001)
  end
end

describe Workerholic::JobScheduler do
  context 'with non-empty set' do
    let(:scheduler) { Workerholic::JobScheduler.new('workerholic:test:scheduled_jobs') }
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

    xit 'fetches a job from a sorted set' do
      score = Time.now.to_f
      scheduler.schedule(serialized_job, score - 1)
      scheduler.poll_scheduled(score)

      expect(scheduler.empty_set?).to eq(true)
    end

    it 'enqueues due job to the main queue'
    it 'checks the sorted set every N seconds'
  end
end
