require 'redis'

require_relative '../spec_helper'
require_relative '../../lib/job'
require_relative '../helpers/job_tests.rb'

describe 'enqueuing jobs to Redis' do
  context 'successfully creates a job and enqueues it in Redis' do
    let(:redis) { Redis.new }

    after { redis.del('test_queue') }

    it 'enqueues a simple job in redis' do
      SimpleJobTest.new.perform_async('test job')
      serialized_job = redis.lpop('test_queue')
      job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

      expect(job_from_redis).to eq({ class: SimpleJobTest, arguments: ['test job'] })
    end

    it 'enqueues a complex job in redis' do
      ComplexJobTest.new.perform_async('test job', { a: 1, b: 2 }, [1, 2, 3])
      serialized_job = redis.lpop('test_queue')
      job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

      expect(job_from_redis).to eq({ class: ComplexJobTest, arguments: ['test job', { a: 1, b: 2 }, [1, 2, 3]] })
    end
  end

  context 'handles user errors' do
    it 'raises an error if Redis server is not running' do
      allow(Workerholic::Storage::RedisWrapper).to receive(:new).and_raise(Redis::CannotConnectError)

      expect { SimpleJobTest.new.perform_async('test job') }.to raise_error(Redis::CannotConnectError)
    end

    it 'raises an error when wrong number of arguments is specified to perform_async' do
      redis = Redis.new
      expect { SimpleJobTest.new.perform_async(1, 2, 3) }.to raise_error(ArgumentError)
      redis.del('test_queue')
    end
  end
end
