require 'redis'

require_relative '../spec_helper'
require_relative '../../lib/job'

class SimpleJobTest
  include Workerholic::Job

  def perform(s)
    s
  end
end

class ComplexJobTest
  include Workerholic::Job

  def perform(arg1, arg2, arg3)
    [arg1, arg2, arg3]
  end
end

describe 'it successfully creates a job and enqueues it in Redis' do
  let(:redis) { Redis.new }

  after { redis.del('test_queue') }

  it 'enqueues a simple job in redis' do
    SimpleJobTest.new.perform_async('test_queue', 'test job')
    serialized_job = redis.lpop('test_queue')
    job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

    expect(job_from_redis).to eq([SimpleJobTest, ['test job']])
  end

  it 'enqueues a complex job in redis' do
    ComplexJobTest.new.perform_async('test_queue', 'test job', { a: 1, b: 2 }, [1, 2, 3])
    serialized_job = redis.lpop('test_queue')
    job_from_redis = Workerholic::JobSerializer.deserialize(serialized_job)

    expect(job_from_redis).to eq([ComplexJobTest, ['test job', { a: 1, b: 2 }, [1, 2, 3]]])
  end
end
