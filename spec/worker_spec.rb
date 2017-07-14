require_relative 'spec_helper'
require_relative '../lib/worker'


describe Workerholic::Worker do
  let(:worker) { Workerholic::Worker.new }
  let(:job) { 'test job' }

  context '#work' do
    it 'can work' do
      allow(worker).to receive(:work)
      worker.work
    end

    it 'polls a job from a thread' do
      # Thread.stub(:new)
      # expect(Thread).to receive(:new).and_yield
      # worker.stub(:poll) { job }
      # worker.stub(:process) { nil }
      # expect(worker).to receive(:poll).and_return('test')

      # worker.work
    end

    it 'processes a job from a thread' do

    end
  end
end
