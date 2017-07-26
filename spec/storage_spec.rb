require_relative 'spec_helper'

describe Workerholic::Storage do
  let(:storage) { Workerholic::Storage::RedisWrapper.new }
  let(:redis) { Redis.new }
  let(:queue_name) { TEST_QUEUE }
  let(:job) { 'test job' }

  before { redis.del(queue_name) }

  context 'with Redis running' do
    it 'adds a job to the test queue' do
      storage.push(queue_name, job)

      expect(storage.list_length(queue_name)).to eq(1)
    end

    it 'pops a job from the test queue' do
      storage.push(queue_name, job)
      storage.pop(queue_name)

      expect(storage.list_length(queue_name)).to eq(0)
    end
  end

  context 'with Redis not running' do
    it 'calls Redis command inside a block wrapper' do
      expect(storage).to receive(:execute)

      storage.list_length(queue_name)
    end

    it 'increments the retries variable on inaccessible Redis instance' do
      expect(storage.redis).to receive(:with).at_least(1).and_raise(Redis::CannotConnectError)

      begin
        storage.push(queue_name, job, 0.01)
      rescue Redis::CannotConnectError
        expect(storage.instance_variable_get(:@retries)).to eq(5)
      end
    end

    it 'raises error if the number of retries has been exceeded' do
      expect(storage.redis).to receive(:with).at_least(1).and_raise(Redis::CannotConnectError)

      expect { storage.push(queue_name, job, 0.01) }.to raise_error(Workerholic::Storage::RedisWrapper::RedisCannotRecover)
    end
  end
end
