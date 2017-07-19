require_relative '../lib/statistics'

describe Workerholic::Statistics do
  it 'initializes attributes with without an argument' do
    statistics = Workerholic::Statistics.new
    expect(statistics.enqueued_at).to be_nil
    expect(statistics.retry_count).to eq(0)
    expect(statistics.errors).to eq([])
    expect(statistics.started_at).to be_nil
    expect(statistics.completed_at).to be_nil
  end
end
