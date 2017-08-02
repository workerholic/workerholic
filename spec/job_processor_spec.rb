require_relative 'spec_helper'

class SimpleJobTestWithError
  include Workerholic::Job
  job_options queue_name: TEST_SCHEDULED_SORTED_SET

  def perform
    raise Exception
  end
end

describe Workerholic::JobProcessor do
  it 'processes a simple job' do
    job = Workerholic::JobWrapper.new(klass: SimpleJobTest, arguments: ['test job'])
    serialized_job = Workerholic::JobSerializer.serialize(job)

    job_processor = Workerholic::JobProcessor.new(serialized_job)
    simple_job_result = SimpleJobTest.new.perform('test job')

    expect(job_processor.process).to eq(simple_job_result)
  end

  it 'processes a complex job' do
    serialized_job = Workerholic::JobSerializer.serialize({
      klass: ComplexJobTest,
      arguments: ['test job', { a: 1, b: 2 }, [1, 2, 3]],
      statistics: Workerholic::JobStatistics.new.to_hash
    })

    job_processor = Workerholic::JobProcessor.new(serialized_job)

    complex_job_result = ComplexJobTest.new.perform('test job', { a: 1, b: 2 }, [1, 2, 3])
    expect(job_processor.process).to eq(complex_job_result)
  end

  it 'does not raise an error when processing a job with error' do
    serialized_job = Workerholic::JobSerializer.serialize({
                       klass: SimpleJobTestWithError,
                       arguments: [],
                       statistics: Workerholic::JobStatistics.new.to_hash
                     })

    job_processor = Workerholic::JobProcessor.new(serialized_job)

    expect { job_processor.process }.not_to raise_error
  end

  it 'retries job when job processing fails' do
    job = {
      klass: SimpleJobTestWithError,
      arguments: [],
      statistics: Workerholic::JobStatistics.new.to_hash
    }
    serialized_job = Workerholic::JobSerializer.serialize(job)
    job_processor = Workerholic::JobProcessor.new(serialized_job)

    expect(job_processor).to receive(:retry_job)

    job_processor.process
  end
end
