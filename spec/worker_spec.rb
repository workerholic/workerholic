require_relative 'spec_helper'

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

  before do
    redis.del(TEST_SCHEDULED_SORTED_SET)
    WorkerJobTest.reset
  end

  context '#work' do
    it 'polls a job from a thread' do
      queue = Workerholic::Queue.new(TEST_QUEUE)
      worker = Workerholic::Worker.new(queue)

      serialized_job = Workerholic::JobSerializer.serialize(job)
      redis.rpush(TEST_QUEUE, serialized_job)

      worker.work

      expect_during(1, false) { redis.exists(TEST_QUEUE) }
    end

    it 'processes a job from a thread' do
      queue = Workerholic::Queue.new(TEST_QUEUE)
      worker = Workerholic::Worker.new(queue)

      serialized_job = Workerholic::JobSerializer.serialize(job)
      redis.rpush(TEST_QUEUE, serialized_job)

      worker.work

      expect_during(1, 1) { WorkerJobTest.check }
    end
  end
end
