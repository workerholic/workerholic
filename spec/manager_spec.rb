require_relative 'spec_helper'

describe Workerholic::Manager do
  it 'creates a number of workers based on workers count' do
    manager = Workerholic::Manager.new

    manager.workers.each { |worker| expect(worker).to be_a(Workerholic::Worker) }
    expect(manager.workers.size).to eq(Workerholic.workers_count)
  end

  it 'creates a job scheduler' do
    manager = Workerholic::Manager.new

    expect(manager.scheduler).to be_a(Workerholic::JobScheduler)
  end

  it 'starts up the workers and the scheduler' do
    manager = Workerholic::Manager.new

    allow_any_instance_of(Workerholic::Worker).to receive(:work) { nil }

    expect(manager.workers.first).to receive(:work)
    expect(manager.scheduler).to receive(:start)

    t = Thread.new { manager.start }
    sleep(0.01)
  end
end
