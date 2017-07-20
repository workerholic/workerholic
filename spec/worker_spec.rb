require 'redis'

require_relative 'spec_helper'
require_relative '../lib/worker'
require_relative '../lib/queue'
require_relative '../lib/statistics'

class WorkerJobTest
  @@job_status = 0

  def self.reset
    @@job_status = 0
  end

  def self.check
    @@job_status
  end

  def perform
    @@job_status += 1
  end
end

def expect_during(duration_in_secs, target)
  timeout = Time.now.to_f + duration_in_secs

  while Time.now.to_f <= timeout
    result = yield
    return if result == target

    sleep(0.001)
  end

  expect(result).to eq(target)
end

describe Workerholic::Worker do
  let(:redis) { Redis.new }
  let(:job) do
    {
      class: WorkerJobTest,
      arguments: [],
      statistics: Workerholic::Statistics.new.to_hash
    }
  end

  before { redis.del('workerholic:test:queue') }
  before { WorkerJobTest.reset }

  context '#work' do
    it 'polls a job from a thread' do
      queue = Workerholic::Queue.new('workerholic:test:queue')
      worker = Workerholic::Worker.new(queue)

      serialized_job = Workerholic::JobSerializer.serialize(job)
      redis.rpush('workerholic:test:queue', serialized_job)

      worker.work

      expect_during(1, false) { redis.exists('workerholic:test:queue') }
    end

    it 'processes a job from a thread' do
      queue = Workerholic::Queue.new('workerholic:test:queue')
      worker = Workerholic::Worker.new(queue)

      serialized_job = Workerholic::JobSerializer.serialize(job)
      redis.rpush('workerholic:test:queue', serialized_job)

      worker.work

      expect_during(1, 1) { WorkerJobTest.check }
    end
  end
end
