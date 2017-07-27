require 'spec_helper'

describe Workerholic::Statistics do
  it 'initializes attributes if no argument supplied' do
    statistics = Workerholic::Statistics.new
    expect(statistics.job_class).to be_nil
    expect(statistics.failed_on).to be_nil
    expect(statistics.job_class).to be_nil
    expect(statistics.enqueued_at).to be_nil
    expect(statistics.errors).to eq([])
    expect(statistics.started_at).to be_nil
    expect(statistics.completed_at).to be_nil
  end

  it 'initializes attributes with arguments' do
    enqueuing_time = Time.now.to_f - 86400
    started_at_time = Time.now.to_f
    completed_at_time = Time.now.to_f + 86400
    elapsed_time = '%.10f' % (completed_at_time - started_at_time)

    options = {
      enqueued_at: enqueuing_time,
      errors: ['Your job is bad and you should feel bad'],
      started_at: started_at_time,
      completed_at: completed_at_time,
      elapsed_time: elapsed_time,
      failed_on: nil,
      job_class: nil
    }

    expect(Workerholic::Statistics.new(options).to_hash).to eq(options)
  end
end
