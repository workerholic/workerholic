require_relative 'spec_helper'

class JobWithError
  def perform
    raise
  end
end

describe Workerholic::JobRetry do
  let(:redis) { Redis.new(url: Workerholic::REDIS_URL) }

  it 'increments retry count' do
    job = Workerholic::JobWrapper.new(class: JobWithError, arguments: [])

    Workerholic::JobRetry.new(
      job: job,
      sorted_set: Workerholic::SortedSet.new(TEST_SCHEDULED_SORTED_SET)
    ).retry

    expect(job.retry_count).to eq(1)
  end

  it 'schedules job by incrementing by 10 more seconds for every new retry' do
    job = Workerholic::JobWrapper.new(class: JobWithError, arguments: [], retry_count: 2)

    Workerholic::JobRetry.new(
      job: job,
      sorted_set: Workerholic::SortedSet.new(TEST_SCHEDULED_SORTED_SET)
    ).retry

    expect((job.execute_at - Time.now.to_f).ceil).to eq(30)
  end

  it 'pushes job inside "workerholic:test:scheduled_jobs" sorted set' do
    job = Workerholic::JobWrapper.new(class: JobWithError, arguments: [], retry_count: 2)

    Workerholic::JobRetry.new(
      job: job,
      sorted_set: Workerholic::SortedSet.new(TEST_SCHEDULED_SORTED_SET)
    ).retry

    serialized_job = Workerholic::JobSerializer.serialize(job)

    expect(redis.zrange(TEST_SCHEDULED_SORTED_SET, 0, 0, with_scores: true).first).to eq([serialized_job, job.execute_at])
  end

  it 'discards job if retry count is greater than 5' do
    job = Workerholic::JobWrapper.new(class: JobWithError, arguments: [], retry_count: 5)

    Workerholic::JobRetry.new(
      job: job,
      sorted_set: Workerholic::SortedSet.new(TEST_SCHEDULED_SORTED_SET)
    ).retry

    expect(redis.exists(TEST_SCHEDULED_SORTED_SET)).to eq(false)
  end
end
