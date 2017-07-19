require 'redis'

require_relative 'spec_helper'

require_relative '../lib/sorted_set'
require_relative '../lib/job_serializer'

require_relative './helpers/job_tests'

describe Workerholic::SortedSet do
  let(:job) {{ class: SimpleJobTest, arguments: [] }}
  let(:redis) { Redis.new }
  let(:sorted_set) { Workerholic::SortedSet.new('workerholic:test:scheduled_jobs') }

  after { redis.del('workerholic:test:scheduled_jobs') }

  it 'adds a serialized job to the sorted set' do
    serialized_job = Workerholic::JobSerializer.serialize(job)
    expect(sorted_set.add(serialized_job)).to eq(true)
  end

  it 'removes due job from the sorted set' do
    serialized_job = Workerholic::JobSerializer.serialize(job)

    sorted_set.add(serialized_job)
    sorted_set.remove

    expect(redis.zcount('workerholic:test:scheduled_jobs', 0, '+inf')).to eq(0)
  end
end
