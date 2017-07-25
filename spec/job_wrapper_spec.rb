require_relative 'spec_helper'

describe Workerholic::JobWrapper do
  it 'returns a hash with job meta info and job stats info' do
    job = Workerholic::JobWrapper.new(class: SimpleJobTest, arguments: ['test job'])

    expected_result = {
      class: SimpleJobTest,
      arguments: ['test job'],
      retry_count: 0,
      execute_at: nil,
      statistics: {
        enqueued_at: nil,
        errors: [],
        started_at: nil,
        completed_at: nil
      }
    }
    expect(job.to_hash).to eq(expected_result)
  end

  it 'performs the job' do
    job = Workerholic::JobWrapper.new(class: SimpleJobTest, arguments: ['test job'])

    expect(job.perform).to eq('test job')
  end
end
