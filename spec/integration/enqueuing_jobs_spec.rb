require 'redis'

require_relative '../spec_helper'
require_relative '../../lib/job'
require_relative '../helpers/job_tests.rb'

describe 'enqueuing jobs to Redis' do
  let(:redis) { Redis.new }
  before { redis.del('workerholic:test:queue') }

  context 'successfully creates a job and enqueues it in Redis' do
    it 'enqueues a simple job in redis' do
      SimpleJobTest.new.perform_async('test job')
      serialized_job = redis.lpop('workerholic:test:queue')
      job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

      expect(job_from_redis).to eq({
        class: SimpleJobTest,
        arguments: ['test job'],
        statistics: {
          enqueued_at: job_from_redis[:statistics][:enqueued_at],
          retry_count: 0,
          errors: [],
          started_at: nil,
          completed_at: nil
        }
      })
    end

    it 'enqueues a complex job in redis' do
      ComplexJobTest.new.perform_async('test job', { a: 1, b: 2 }, [1, 2, 3])
      serialized_job = redis.lpop('workerholic:test:queue')
      job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

      expect(job_from_redis).to eq({
        class: ComplexJobTest,
        arguments: ['test job', { a: 1, b: 2 }, [1, 2, 3]],
        statistics: {
          enqueued_at: job_from_redis[:statistics][:enqueued_at],
          retry_count: 0,
          errors: [],
          started_at: nil,
          completed_at: nil
        }
      })
    end

    it 'enqueues a job with the right statistics' do
      SimpleJobTest.new.perform_async('test_job')
      serialized_job = redis.lpop('workerholic:test:queue')
      job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

      expect(job_from_redis[:statistics][:enqueued_at]).to be < Time.now.to_f
    end
  end

  context 'handles user errors' do
    it 'raises an error if Redis server is not running' do
      allow(Workerholic::Storage::RedisWrapper).to receive(:new).and_raise(Redis::CannotConnectError)

      expect { SimpleJobTest.new.perform_async('test job') }.to raise_error(Redis::CannotConnectError)
    end

    it 'raises an error when wrong number of arguments is specified to perform_async' do
      expect { SimpleJobTest.new.perform_async(1, 2, 3) }.to raise_error(ArgumentError)
    end
  end
end
