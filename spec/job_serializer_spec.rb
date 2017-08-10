require_relative 'spec_helper'

class JobTest; end

describe Workerholic::JobSerializer do
  it 'serializes a job' do
    job = Workerholic::JobWrapper.new(
      klass: JobTest,
      wrapper: JobTest,
      arguments: ['some_args', [1, 2, 3], true, { a: 'y' }, 1, :symptom]
    )

    serialized_job = Workerholic::JobSerializer.serialize(job)

    expect(serialized_job).to eq(JSON.dump(job.to_hash))
  end

  it 'deserializes a job' do
    job = Workerholic::JobWrapper.new(
      klass: JobTest,
      wrapper: JobTest,
      arguments: ['some_args', [1, 2, 3], true, { a: 'y' }, 1, :symptom]
    )

    serialized_job = JSON.dump(job.to_hash)
    deserialized_job = Workerholic::JobSerializer.deserialize(serialized_job)

    expect(deserialized_job) == job
  end

  it 'deserializes statistics' do
    serialized_stats = JSON.dump({ klass: SimpleJobTest, wrapper: SimpleJobTest })

    deserialized_stats = Workerholic::JobSerializer.deserialize_stats(serialized_stats)

    expect(deserialized_stats).to eq({ klass: 'SimpleJobTest', wrapper: 'SimpleJobTest' })
  end
end
