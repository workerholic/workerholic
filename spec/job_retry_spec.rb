require_relative 'spec_helper'
require_relative '../lib/job_retry'

class JobWithError
  def perform
    raise
  end
end

describe Workerholic::JobRetry do
  let(:redis) { Redis.new }

  before { redis.del(TEST_SCHEDULED_SORTED_SET) }

  it 'increments retry count' do
    job = {
      class: JobWithError,
      arguments: [],
      retry_count: 0,
      execute_at: nil
    }

    Workerholic::JobRetry.new(
      job: job,
      sorted_set: Workerholic::SortedSet.new(TEST_SCHEDULED_SORTED_SET)
    )

    expect(job[:retry_count]).to eq(1)
  end

  it 'schedules job by incrementing by 10 more seconds for every new retry' do
    job = {
      class: JobWithError,
      arguments: [],
      retry_count: 2,
      execute_at: nil
    }

    Workerholic::JobRetry.new(
      job: job,
      sorted_set: Workerholic::SortedSet.new(TEST_SCHEDULED_SORTED_SET)
    )

    expect((job[:execute_at] - Time.now.to_f).ceil).to eq(30)
  end

  it 'pushes job inside "workerholic:test:scheduled_jobs" sorted set' do
    job = {
      class: JobWithError,
      arguments: [],
      retry_count: 2,
      execute_at: nil
    }

    Workerholic::JobRetry.new(
      job: job,
      sorted_set: Workerholic::SortedSet.new(TEST_SCHEDULED_SORTED_SET)
    )

    serialized_job = Workerholic::JobSerializer.serialize(job)

    expect(redis.zrange(TEST_SCHEDULED_SORTED_SET, 0, 0, with_scores: true).first).to eq([serialized_job, job[:execute_at]])
  end

  it 'discards job if retry count is greater than 5' do
    job = {
      class: JobWithError,
      arguments: [],
      retry_count: 5,
      execute_at: nil
    }

    Workerholic::JobRetry.new(
      job: job,
      sorted_set: Workerholic::SortedSet.new(TEST_SCHEDULED_SORTED_SET)
    )

    expect(redis.exists(TEST_SCHEDULED_SORTED_SET)).to eq(false)
  end
end
