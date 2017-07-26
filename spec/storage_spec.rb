require_relative 'spec_helper'

describe Workerholic::Storage do
  let(:storage) { Workerholic::Storage::RedisWrapper.new }
  let(:queue_name) { TEST_QUEUE }
  let(:job) { 'test job' }

  before { storage.redis.del(queue_name) }

  context 'with Redis running' do
    it 'adds a job to the test queue' do
      expect(storage.redis).to receive(:rpush).with(queue_name, job)
      storage.push(queue_name, job)
    end

    it 'pops a job from the test queue' do
      expect(storage.redis).to receive(:blpop).with(queue_name, 1)
      storage.pop(queue_name)
    end
  end

  context 'with Redis not running' do
    it 'calls Redis command inside a block wrapper' do
      expect(storage).to receive(:execute)

      storage.list_length(queue_name)
    end

    it 'increments the retries variable on inaccessible Redis instance' do
      allow(storage.redis).to receive(:rpush).and_raise(Redis::CannotConnectError)

      t = Thread.new { storage.push(queue_name, job) }

      sleep(0.1)
      t.kill

      expect(storage.instance_variable_get(:@retries)).to eq(1)
    end

    it 'raises error if the number of retries has been exceeded' do
      allow(storage.redis).to receive(:rpush).and_raise(Redis::CannotConnectError)

      t = Thread.new { storage.push(queue_name, job, 0.1) }

      sleep 0.5

      expect(storage.instance_variable_get(:@retries)).to eq(5)
      expect { t.join }.to raise_error(Workerholic::Storage::RedisWrapper::RedisCannotRecover)
    end
  end
end
