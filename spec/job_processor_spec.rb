require_relative 'spec_helper.rb'

require_relative '../lib/job_processor'
require_relative './helpers/job_tests'

class SimpleJobTestWithError
  include Workerholic::Job

  def perform
    raise Exception
  end

  def queue_name
    TEST_QUEUE
  end
end

describe Workerholic::JobProcessor do
  it 'processes a simple job' do
    serialized_job = Workerholic::JobSerializer.serialize({
      class: SimpleJobTest,
      arguments: ['test job'],
      statistics: Workerholic::Statistics.new.to_hash
    })

    job_processor = Workerholic::JobProcessor.new(serialized_job)
    simple_job_result = SimpleJobTest.new.perform('test job')

    expect(job_processor.process).to eq(simple_job_result)
  end

  it 'processes a complex job' do
    serialized_job = Workerholic::JobSerializer.serialize({
      class: ComplexJobTest,
      arguments: ['test job', { a: 1, b: 2 }, [1, 2, 3]],
      statistics: Workerholic::Statistics.new.to_hash
    })

    job_processor = Workerholic::JobProcessor.new(serialized_job)

    complex_job_result = ComplexJobTest.new.perform('test job', { a: 1, b: 2 }, [1, 2, 3])
    expect(job_processor.process).to eq(complex_job_result)
  end

  # it 'raises a custom error when processing a job with error' do
  #   serialized_job = Workerholic::JobSerializer.serialize({
  #                      class: SimpleJobTestWithError,
  #                      arguments: [],
  #                      statistics: Workerholic::Statistics.new.to_hash
  #                    })

  #   job_processor = Workerholic::JobProcessor.new(serialized_job)

  #   expect { job_processor.process }.to raise_error(Workerholic::JobProcessingError)
  # end

  it 'retries job when job processing fails' do
    job = {
      class: SimpleJobTestWithError,
      arguments: [],
      statistics: Workerholic::Statistics.new.to_hash
    }
    serialized_job = Workerholic::JobSerializer.serialize(job)

    Workerholic::JobRetry.stub(:new)
    expect(Workerholic::JobRetry).to receive(:new)

    Workerholic::JobProcessor.new(serialized_job).process
  end
end
