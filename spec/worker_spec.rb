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

describe Workerholic::Worker do
  let(:redis) { Redis.new }
  let(:job) do
    {
      class: WorkerJobTest,
      arguments: [],
      statistics: Workerholic::Statistics.new.to_hash
    }
  end

  before { redis.del('test_queue') }
  before { WorkerJobTest.reset }

  context '#work' do
    it 'polls a job from a thread' do
      queue = Workerholic::Queue.new('test_queue')
      worker = Workerholic::Worker.new(queue)

      serialized_job = Workerholic::JobSerializer.serialize(job)
      redis.rpush('test_queue', serialized_job)

      worker.work
      sleep(0.01)

      expect(redis.exists('test_queue')).to eq(false)
    end

    it 'processes a job from a thread' do
      queue = Workerholic::Queue.new('test_queue')
      worker = Workerholic::Worker.new(queue)

      serialized_job = Workerholic::JobSerializer.serialize(job)
      redis.rpush('test_queue', serialized_job)

      worker.work
      sleep(0.01)

      expect(WorkerJobTest.check).to eq(1)
    end
  end
end
