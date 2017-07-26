require_relative 'spec_helper'

TESTED_QUEUES = [BALANCER_TEST_QUEUE, ANOTHER_BALANCER_TEST_QUEUE]

describe Workerholic::WorkerBalancer do
  let(:storage) { Workerholic::Storage::RedisWrapper.new }

  before do
    100.times do |n|
      FirstJobBalancerTest.new.perform_async('first string', n)
      SecondJobBalancerTest.new.perform_async('second string', n)
    end
  end

  after do
    storage.redis.del(*[BALANCER_TEST_QUEUE, ANOTHER_BALANCER_TEST_QUEUE])
  end

  it 'fetches queues' do
    allow(Workerholic::WorkerBalancer.new).to receive(:fetch_queues).and_return TESTED_QUEUES

    manager = Workerholic::WorkerBalancer.new(workers: [])

    expect(manager.queues.map(&:name)).to match_array TESTED_QUEUES
  end

  it 'calculates total number of jobs for all queues' do
    manager = Workerholic::WorkerBalancer.new(workers: [])
    manager.send(:fetch_queues)
    total_jobs = manager.send(:total_jobs)

    expect(total_jobs).to eq(200)
  end

  it 'autobalances workers' do
    workers = []
    25.times { workers << Workerholic::Worker.new }
    manager = Workerholic::WorkerBalancer.new(workers: workers)
    #t = manager.send(:auto_balance_workers)


  end
  it 'evenly balances workers without any supplied arguments'
end
