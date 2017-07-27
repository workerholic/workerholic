require_relative 'spec_helper'

describe Workerholic::SortedSet do
  let(:job) {{ class: SimpleJobTest, arguments: [] }}
  let(:redis) { Redis.new }
  let(:sorted_set) { Workerholic::SortedSet.new(TEST_SCHEDULED_SORTED_SET) }

  it 'adds a serialized job to the sorted set' do
    serialized_job = Workerholic::JobSerializer.serialize(job)
    score = Time.now.to_f

    expect(sorted_set.storage).to receive(:add_to_set).and_return(true)

    sorted_set.add(serialized_job, score)
  end

  it 'removes due job from the sorted set' do
    serialized_job = Workerholic::JobSerializer.serialize(job)
    score = Time.now.to_f
    redis.zadd(TEST_SCHEDULED_SORTED_SET, score, serialized_job)

    sorted_set.remove(score)

    expect(redis.zcount(TEST_SCHEDULED_SORTED_SET, 0, '+inf')).to eq(0)
  end

  it 'returns first element from sorted set' do
    expect(sorted_set.storage).to receive(:peek)

    sorted_set.peek
  end

  it 'checks if set is empty' do
    expect(sorted_set.storage).to receive(:sorted_set_size)

    sorted_set.empty?
  end
end
