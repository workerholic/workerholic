require_relative '../spec_helper'

describe 'enqueuing jobs to Redis' do
  let(:redis) { Redis.new }

  context 'successfully creates a job and enqueues it in Redis' do
    it 'enqueues a simple job in redis' do
      SimpleJobTest.new.perform_async('test job')
      serialized_job = redis.lpop(TEST_QUEUE)
      job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

      expected_job = Workerholic::JobWrapper.new(klass: SimpleJobTest, arguments: ['test job'], wrapper: SimpleJobTest)
      expected_job.statistics.enqueued_at = job_from_redis.statistics.enqueued_at

      expect(job_from_redis.to_hash).to eq(expected_job.to_hash)
    end

    it 'enqueues a complex job in redis' do
      ComplexJobTest.new.perform_async('test job', { a: 1, b: 2 }, [1, 2, 3])
      serialized_job = redis.lpop(TEST_QUEUE)
      job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

      expected_job = Workerholic::JobWrapper.new(
        klass: ComplexJobTest,
        arguments: ['test job', { a: 1, b: 2 }, [1, 2, 3]],
        wrapper: ComplexJobTest
      )

      expected_job.statistics.enqueued_at = job_from_redis.statistics.enqueued_at

      expect(job_from_redis.to_hash).to eq(expected_job.to_hash)
    end

    xit 'enqueues a delayed job in redis' do
      DelayedJobTest.new.perform_delayed(100, 'test job')
      serialized_job = redis.lpop(TEST_QUEUE)
      job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

      expected_job = Workerholic::JobWrapper.new(klass: SimpleJobTest, arguments: ['test job'], wrapper: SimpleJobTest)
      expected_job.statistics.enqueued_at = job_from_redis.statistics.enqueued_at

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

    it 'raises an ArgumentError if perform_delayed first argument is not of Numeric type' do
      job = DelayedJobTest.new

      expect { job.perform_delayed('wrong type', 'test arg') }.to raise_error(ArgumentError)
    end
  end
end
