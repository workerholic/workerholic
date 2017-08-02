require_relative '../spec_helper'

describe 'dequeuing and processesing of jobs' do
  let(:redis) { Redis.new(url: Workerholic::REDIS_URL) }

  xit 'successfully dequeues and process a simple job' do
    serialized_job = Workerholic::JobSerializer.serialize(
      class: SimpleJobTest,
      arguments: ['test job']
    )
    redis.rpush(TEST_QUEUE, serialized_job)
    manager = Workerholic::Manager.new

    Thread.new { manager.start }
    sleep(0.05)

    expect(redis.llen(TEST_QUEUE)).to eq(0)
    Thread.list.reject { |t| t == Thread.main }.each(&:kill)
  end

  it 'successfully dequeues and process a complex job'

  context 'user interrupts process' do
    it 'finishes executing the current job before gracefully shutting down'
  end
end
