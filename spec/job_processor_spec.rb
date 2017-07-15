require_relative "./spec_helper.rb"

require_relative "../lib/job_processor.rb"
require_relative "./helpers/job_tests.rb"

describe Workerholic::JobProcessor do
  it "processes a simple job" do
    serialized_job = Workerholic::JobSerializer.serialize([SimpleJobTest, ['test job']])
    job_processor = Workerholic::JobProcessor.new(serialized_job)
    simple_job_result = SimpleJobTest.new.perform("test job")

    expect(job_processor.process).to eq(simple_job_result)
  end

  it "processes a complex job" do
    serialized_job = Workerholic::JobSerializer.serialize([ComplexJobTest, ['test job', { a: 1, b: 2 }, [1, 2, 3]]])
    job_processor = Workerholic::JobProcessor.new(serialized_job)
    complex_job_result = ComplexJobTest.new.perform('test job', { a: 1, b: 2 }, [1, 2, 3])

    expect(job_processor.process).to eq(complex_job_result)
  end
end
