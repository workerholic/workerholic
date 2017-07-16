require_relative './spec_helper.rb'

require_relative '../lib/job_processor.rb'
require_relative './helpers/job_tests.rb'

class SimpleJobTestWithError
  include Workerholic::Job

  def perform
    raise Exception
  end

  def queue_name
    'test_queue'
  end
end

describe Workerholic::JobProcessor do
  it 'processes a simple job' do
    serialized_job = Workerholic::JobSerializer.serialize([SimpleJobTest, ['test job']])
    job_processor = Workerholic::JobProcessor.new(serialized_job)
    simple_job_result = SimpleJobTest.new.perform('test job')

    expect(job_processor.process).to eq(simple_job_result)
  end

  it 'processes a complex job' do
    serialized_job = Workerholic::JobSerializer.serialize([ComplexJobTest, ['test job', { a: 1, b: 2 }, [1, 2, 3]]])
    job_processor = Workerholic::JobProcessor.new(serialized_job)
    complex_job_result = ComplexJobTest.new.perform('test job', { a: 1, b: 2 }, [1, 2, 3])

    expect(job_processor.process).to eq(complex_job_result)
  end

  it 'raises a custom error when processing a job with error' do
    serialized_job = Workerholic::JobSerializer.serialize([SimpleJobTestWithError, []])
    job_processor = Workerholic::JobProcessor.new(serialized_job)

    expect { job_processor.process }.to raise_error(Workerholic::JobProcessingError)
  end
end
