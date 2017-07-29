require_relative 'spec_helper'

describe Workerholic::Queue do
  let(:redis) { Redis.new }
  let(:queue) { Workerholic::Queue.new(TEST_QUEUE) }
  let(:job) { 'test job' }

  it 'enqueues a job' do
    expect(queue.storage).to receive(:push).with(queue.name, job)
    queue.enqueue(job)
  end

  it 'dequeues a job' do
    expect(queue.storage).to receive(:pop).with(queue.name).and_return([queue.name,job])
    queue.dequeue
  end

  it 'checks if queue is empty' do
    expect(queue.empty?).to eq(true)
  end

  it 'returns size of queue' do
    redis.rpush(TEST_QUEUE, job)
    redis.rpush(TEST_QUEUE, job)
    redis.rpush(TEST_QUEUE, job)

    expect(queue.size).to eq(3)
  end
end
