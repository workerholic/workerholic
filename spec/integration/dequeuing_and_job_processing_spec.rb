require 'redis'

require_relative '../spec_helper'
require_relative '../../lib/job'
require_relative '../../lib/manager'


class SimpleJobTest
  include Workerholic::Job

  @@job_status = false

  def self.reset
    @@job_status = false
  end

  def perform
    @@job_status = true
  end
end

class ComplexJobTest
  include Workerholic::Job

  def perform(arg1, arg2, arg3)
    [arg1, arg2, arg3]
  end
end

describe 'it successfully dequeues a job and processes it' do
  let(:redis) { Redis.new }

  after { SimpleJobTest.reset }

  it 'successfully dequeues and process a simple job' do
    # serialized_job = Workerholic::JobSerializer.serialize([SimpleJobTest, ['test job']])
    # redis.rpush('test_queue', serialized_job)
    #
    # Workerholic::Manager.new(1).start
    # expect(redis.exists('test_queue')).to eq(false)
  end

  it 'successfully dequeues and process a complex job' do
    # serialized_job = Workerholic::JobSerializer.serialize([ComplexJobTest, ['test job']])
    # redis.rpush('test_queue', serialized_job)
    #
    # Workerholic::Manager.new.start
    # expect(redis.exists('test_queue')).to eq(false)
  end
end
