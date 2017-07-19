require_relative 'spec_helper'
require_relative '../lib/job_serializer'

class JobTest; end

describe Workerholic::JobSerializer do
  it 'serializes a job' do
    job = {
      class: JobTest,
      arguments: ['some_args', [1, 2, 3], true, { a: 'y' }, 1, :symptom]
    }

    serialized_job = Workerholic::JobSerializer.serialize(job)

    result = "---\n:class: !ruby/class 'JobTest'\n:arguments:\n- some_args\n- - 1\n  - 2\n  - 3\n- true\n- :a: y\n- 1\n- :symptom\n"
    expect(serialized_job).to eq(result)
  end

  it 'deserializes a job' do
    serialized_job = "---\n:class: !ruby/class 'JobTest'\n:arguments:\n- some_args\n- - 1\n  - 2\n  - 3\n- true\n- :a: y\n- 1\n- :symptom\n"

    deserialized_job = Workerholic::JobSerializer.deserialize(serialized_job)

    result = {
      class: JobTest,
      arguments: ['some_args', [1, 2, 3], true, { a: 'y' }, 1, :symptom]
    }
    expect(deserialized_job).to eq(result)
  end
end
