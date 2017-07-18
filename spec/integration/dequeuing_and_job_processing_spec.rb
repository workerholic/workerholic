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

  def queue_name
    'test_queue'
  end
end

class ComplexJobTest
  include Workerholic::Job

  def perform(arg1, arg2, arg3)
    [arg1, arg2, arg3]
  end

  def queue_name
    'test_queue'
  end
end

describe 'dequeuing and processesing of jobs' do
  let(:redis) { Redis.new }

  it 'successfully dequeues and process a simple job' do
    # serialized_job = Workerholic::JobSerializer.serialize([SimpleJobTest, ['test job']])
    # redis.rpush('test_queue', serialized_job)

    # Workerholic::Manager.new(1).start
    # expect(redis.exists('test_queue')).to eq(false)
    # SimpleJobTest.reset
  end

  it 'successfully dequeues and process a complex job' do
  end

  context 'performing the job raises an error' do
  end
end
