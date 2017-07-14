require_relative 'spec_helper'
require_relative '../lib/storage'

describe Workerholic::Storage do
  let(:storage) { Workerholic::Storage::RedisWrapper.new }
  let(:queue_name) { 'test_queue' }
  let(:job) { 'test job' }

  it 'adds a job to the test queue' do
    expect(storage.redis).to receive(:rpush).with(queue_name, job)
    storage.push(queue_name, job)
  end

  it 'pops a job from the test queue' do
    expect(storage.redis).to receive(:blpop).with(queue_name, 0)
    storage.pop(queue_name)
  end
end
