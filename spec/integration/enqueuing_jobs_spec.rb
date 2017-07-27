require_relative '../spec_helper'

describe 'enqueuing jobs to Redis' do
  let(:redis) { Redis.new }
  before { redis.del(TEST_QUEUE) }

  context 'successfully creates a job and enqueues it in Redis' do
    it 'enqueues a simple job in redis' do
      SimpleJobTest.new.perform_async('test job')
      serialized_job = redis.lpop(TEST_QUEUE)
      job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

      expected_job = Workerholic::JobWrapper.new(class: SimpleJobTest, arguments: ['test job'])
      expected_job.statistics.enqueued_at = job_from_redis.statistics.enqueued_at
      expected_job.statistics.job_class = job_from_redis.statistics.job_class

      expect(job_from_redis.to_hash).to eq(expected_job.to_hash)
    end

    it 'enqueues a complex job in redis' do
      ComplexJobTest.new.perform_async('test job', { a: 1, b: 2 }, [1, 2, 3])
      serialized_job = redis.lpop(TEST_QUEUE)
      job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

      expected_job = Workerholic::JobWrapper.new(
        class: ComplexJobTest,
        arguments: ['test job', { a: 1, b: 2 }, [1, 2, 3]]
      )

      expected_job.statistics.enqueued_at = job_from_redis.statistics.enqueued_at
      expected_job.statistics.job_class = job_from_redis.statistics.job_class

      expect(job_from_redis.to_hash).to eq(expected_job.to_hash)
    end

    it 'enqueues a job with the right statistics' do
      SimpleJobTest.new.perform_async('test_job')
      serialized_job = redis.lpop(TEST_QUEUE)
      job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

      expect(job_from_redis.statistics.enqueued_at).to be < Time.now.to_f
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
