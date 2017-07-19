require_relative 'spec_helper'
require_relative '../lib/job_retry'

class JobWithError
  def perform
    raise
  end
end

describe Workerholic::JobRetry do
  let(:redis) { Redis.new }

  it 'increments number of retries' do
    job = {
      class: JobWithError,
      arguments: [],
      retries: 0,
      execute_at: nil
    }

    Workerholic::JobRetry.new(
      job: job,
      sorted_set: Workerholic::SortedSet.new('workerholic:test:scheduled_jobs')
    )

    expect(job[:retries]).to eq(1)
  end

  it 'schedules job by incrementing by 10 more seconds for every new retry' do
    job = {
      class: JobWithError,
      arguments: [],
      retries: 2,
      execute_at: nil
    }

    Workerholic::JobRetry.new(
      job: job,
      sorted_set: Workerholic::SortedSet.new('workerholic:test:scheduled_jobs')
    )

    expect((job[:execute_at] - Time.now.to_f).ceil).to eq(30)
  end

  it 'pushes job inside "workerholic:test:scheduled_jobs" sorted set' do
    job = {
      class: JobWithError,
      arguments: [],
      retries: 2,
      execute_at: nil
    }

    Workerholic::JobRetry.new(
      job: job,
      sorted_set: Workerholic::SortedSet.new('workerholic:test:scheduled_jobs')
    )

    serialized_job = Workerholic::JobSerializer.serialize(job)

    expect(redis.zrange('workerholic:test:scheduled_jobs', 0, 0, with_scores: true)).to eq([serialized_job, job[:execute_at]])
  end

  it 'discards job if number of retries is greater than 5'
end
