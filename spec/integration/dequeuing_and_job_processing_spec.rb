require_relative '../spec_helper'

describe 'dequeuing and processesing of jobs' do
  let(:redis) { Redis.new }
  before { redis.del(TEST_QUEUE) }

  xit 'successfully dequeues and process a simple job' do
    serialized_job = Workerholic::JobSerializer.serialize(
      class: SimpleJobTest,
      arguments: ['test job']
    )
    redis.rpush(TEST_QUEUE, serialized_job)
    manager = Workerholic::Manager.new

    Thread.new { manager.start }
    expect_during(1, false) { redis.exists(TEST_QUEUE) }
  end

  it 'successfully dequeues and process a complex job'

  context 'user interrupts process' do
    it 'finishes executing the current job before gracefully shutting down'
  end
end
