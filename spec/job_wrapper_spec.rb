require_relative 'spec_helper'

describe Workerholic::JobWrapper do
  it 'returns a hash with job meta info and job stats info' do
    job = Workerholic::JobWrapper.new(klass: SimpleJobTest, arguments: ['test job'], queue: TEST_QUEUE)

    expected_result = {
      klass: SimpleJobTest,
      wrapper: nil,
      arguments: ['test job'],
      queue: TEST_QUEUE,
      retry_count: 0,
      execute_at: nil,
      statistics: {
        enqueued_at: nil,
        errors: [],
        started_at: nil,
        completed_at: nil,
        failed_on: nil,
        elapsed_time: nil
      }
    }
    expect(job.to_hash).to eq(expected_result)
  end

  it 'performs the job' do
    job = Workerholic::JobWrapper.new(klass: SimpleJobTest, arguments: ['test job'])

    expect(job.perform).to eq('test job')
  end
end
