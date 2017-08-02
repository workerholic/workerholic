require_relative 'spec_helper'

describe Workerholic::JobScheduler do
  let(:scheduler) do
    Workerholic::JobScheduler.new(
      sorted_set: Workerholic::SortedSet.new(TEST_SCHEDULED_SORTED_SET),
      queue_name: TEST_QUEUE
    )
  end

  let(:redis) { Redis.new }

  context 'with non-empty set' do
    let(:serialized_job) do
      job = Workerholic::JobWrapper.new(
        class: ComplexJobTest,
        arguments: ['test job', { a: 1, b: 2 }, [1, 2, 3]]
      )

      Workerholic::JobSerializer.serialize(job)
    end

    it 'checks the time for scheduled job inside sorted set' do
      score = Time.now.to_f
      scheduler.schedule(serialized_job, score)

      expect(scheduler.job_due?).to eq(true)
    end

    it 'fetches a job from a sorted set' do
      score = Time.now.to_f
      scheduler.schedule(serialized_job, score)
      scheduler.enqueue_due_jobs

      expect(scheduler.sorted_set.empty?).to eq(true)
    end

    it 'enqueues due job to the main queue' do
      score = Time.now.to_f
      scheduler.schedule(serialized_job, score)
      scheduler.enqueue_due_jobs

      expect(scheduler.queue.empty?).to eq(false)
      expect(scheduler.queue.dequeue).to eq(serialized_job)
    end
  end
end
