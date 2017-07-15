require 'redis'

require_relative '../spec_helper'
require_relative '../../lib/job'
require_relative '../helpers/job_tests.rb'

describe 'it successfully creates a job and enqueues it in Redis' do
  let(:redis) { Redis.new }

  after { redis.del('test_queue') }

  it 'enqueues a simple job in redis' do
    SimpleJobTest.new.perform_async('test job')
    serialized_job = redis.lpop('test_queue')
    job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

    expect(job_from_redis).to eq([SimpleJobTest, ['test job']])
  end

  it 'enqueues a complex job in redis' do
    ComplexJobTest.new.perform_async('test job', { a: 1, b: 2 }, [1, 2, 3])
    serialized_job = redis.lpop('test_queue')
    job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

    expect(job_from_redis).to eq([ComplexJobTest, ['test job', { a: 1, b: 2 }, [1, 2, 3]]])
  end
end
