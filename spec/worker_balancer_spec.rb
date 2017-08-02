require_relative 'spec_helper'

TESTED_QUEUES = [
  WORKERHOLIC_QUEUE_NAMESPACE + BALANCER_TEST_QUEUE,
  WORKERHOLIC_QUEUE_NAMESPACE + ANOTHER_BALANCER_TEST_QUEUE
]

describe Workerholic::WorkerBalancer do
  let(:storage) { Workerholic::Storage::RedisWrapper.new }
  let(:redis) { Redis.new(url: Workerholic::REDIS_URL) }

  before do
    100.times do |n|
      FirstJobBalancerTest.new.perform_async('first string', n)
      SecondJobBalancerTest.new.perform_async('second string', n)
    end
  end

  it 'fetches queues' do
    allow(Workerholic::WorkerBalancer.new).to receive(:fetch_queues).and_return(TESTED_QUEUES)

    balancer = Workerholic::WorkerBalancer.new(workers: [])

    expect(balancer.queues.map(&:name)).to match_array(TESTED_QUEUES)
  end
end
