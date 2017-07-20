require_relative 'spec_helper'
require_relative '../lib/job_serializer'
require_relative '../lib/statistics'

class JobTest; end

describe Workerholic::JobSerializer do
  it 'serializes a job' do
    job = {
      class: JobTest,
      arguments: ['some_args', [1, 2, 3], true, { a: 'y' }, 1, :symptom],
      statistics: Workerholic::Statistics.new.to_hash
    }

    serialized_job = Workerholic::JobSerializer.serialize(job)

    result = "---\n:class: !ruby/class 'JobTest'\n:arguments:\n- some_args\n- - 1\n  - 2\n  - 3\n- true\n- :a: y\n- 1\n- :symptom\n:statistics:\n  :enqueued_at: \n  :retry_count: 0\n  :errors: []\n  :started_at: \n  :completed_at: \n"

    expect(serialized_job).to eq(result)
  end

  it 'deserializes a job' do
    serialized_job = "---\n:class: !ruby/class 'JobTest'\n:arguments:\n- some_args\n- - 1\n  - 2\n  - 3\n- true\n- :a: y\n- 1\n- :symptom\n:statistics:\n  :enqueued_at: \n  :retry_count: 0\n  :errors: []\n  :started_at: \n  :completed_at: \n"

    deserialized_job = Workerholic::JobSerializer.deserialize(serialized_job)

    result = {
      class: JobTest,
      arguments: ['some_args', [1, 2, 3], true, { a: 'y' }, 1, :symptom],
      statistics: Workerholic::Statistics.new.to_hash
    }

    expect(deserialized_job).to eq(result)
  end
end
