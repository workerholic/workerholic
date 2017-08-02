require_relative 'spec_helper'

describe Workerholic::Storage do
  let(:storage) { Workerholic::Storage::RedisWrapper.new }
  let(:redis) { Redis.new(url: Workerholic::REDIS_URL) }
  let(:queue_name) { TEST_QUEUE }
  let(:job) { 'test job' }

  context 'with Redis running' do
    it 'adds a job to the test queue' do
      storage.push(queue_name, job)

      expect(redis.llen(queue_name)).to eq(1)
    end

    it 'pops a job from the test queue' do
      storage.push(queue_name, job)
      storage.pop(queue_name)

      expect(storage.list_length(queue_name)).to eq(0)
    end

    it 'gets the size for a specific queue' do
      storage.push(queue_name, job)
      storage.push(queue_name, job)

      expect(storage.list_length(queue_name)).to eq(2)
    end

    it 'adds job to sorted set' do
      score = Time.now.to_f
      storage.add_to_set(TEST_SCHEDULED_SORTED_SET, score, job)

      expect(redis.zrange(TEST_SCHEDULED_SORTED_SET, 0, 0, with_scores: true).first).to eq([job, score])
    end

    it 'returns first element in sorted set' do
      score = Time.now.to_f
      redis.zadd(TEST_SCHEDULED_SORTED_SET, score, job)

      expect(storage.peek(TEST_SCHEDULED_SORTED_SET)).to eq([job, score])
    end

    it 'removes specified element from set' do
      score1 = Time.now.to_f
      score2 = score1 + 10
      job2 = 'second test job'
      redis.zadd(TEST_SCHEDULED_SORTED_SET, score1, job)
      redis.zadd(TEST_SCHEDULED_SORTED_SET, score2, job2)

      expect(storage.remove_from_set(TEST_SCHEDULED_SORTED_SET, score1)).to eq(1)
      expect(redis.zcount(TEST_SCHEDULED_SORTED_SET, 0, '+inf')).to eq(1)
    end

    it 'checks if the sorted set is empty' do
      score1 = Time.now.to_f
      score2 = score1 + 10
      job2 = 'second test job'
      redis.zadd(TEST_SCHEDULED_SORTED_SET, score1, job)
      redis.zadd(TEST_SCHEDULED_SORTED_SET, score2, job2)

      expect(storage.sorted_set_size(TEST_SCHEDULED_SORTED_SET)).to eq(2)
    end

    it 'returns the workerholic queue names that are in redis' do
      storage.push(WORKERHOLIC_QUEUE_NAMESPACE + queue_name, job)
      storage.push(WORKERHOLIC_QUEUE_NAMESPACE + ANOTHER_TEST_QUEUE, job)

      expect(storage.fetch_queue_names).to match_array([WORKERHOLIC_QUEUE_NAMESPACE + queue_name, WORKERHOLIC_QUEUE_NAMESPACE + ANOTHER_TEST_QUEUE])
    end

    it 'sets k and a value to a hash in redis' do
      storage.hash_set(HASH_TEST, 'key_test', 1234)

      expect(redis.hget(HASH_TEST, 'key_test')).to eq('1234')
    end

    it 'gets the value for a given key of a hash in redis' do
      redis.hset(HASH_TEST, 'key_test', 1234)

      expect(storage.hash_get(HASH_TEST, 'key_test')).to eq('1234')
    end

    it 'deletes a key from redis' do
      redis.set(TEST_QUEUE, 'something')
      storage.delete(TEST_QUEUE)

      expect(redis.exists(TEST_QUEUE)).to eq(false)
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
