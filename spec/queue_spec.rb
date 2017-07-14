require_relative 'spec_helper'
require_relative '../lib/queue'

describe Workerholic::Queue do
  let(:queue) { Workerholic::Queue.new('test') }
  let(:job) { 'test job' }

  it 'enqueues a job' do
    expect(queue.storage).to receive(:push).with(queue.name, job)
    queue.enqueue(job)
  end

  it 'dequeues a job' do
    expect(queue.storage).to receive(:pop).with(queue.name).and_return([queue.name,job])
    queue.dequeue
  end
end
