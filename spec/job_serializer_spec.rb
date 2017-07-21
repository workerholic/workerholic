require_relative 'spec_helper'
require_relative '../lib/job_serializer'
require_relative '../lib/statistics'
require_relative '../lib/job_wrapper'

class JobTest; end

describe Workerholic::JobSerializer do
  it 'serializes a job' do
    job = Workerholic::JobWrapper.new(
      class: JobTest,
      arguments: ['some_args', [1, 2, 3], true, { a: 'y' }, 1, :symptom]
    )

    serialized_job = Workerholic::JobSerializer.serialize(job)

    expect(serialized_job).to eq(YAML.dump(job.to_hash))
  end

  it 'deserializes a job' do
    job = Workerholic::JobWrapper.new(
      class: JobTest,
      arguments: ['some_args', [1, 2, 3], true, { a: 'y' }, 1, :symptom]
    )

    serialized_job = YAML.dump(job.to_hash)
    deserialized_job = Workerholic::JobSerializer.deserialize(serialized_job)

    expect(deserialized_job).to eq(job)
  end
end
