require_relative 'spec_helper'

TESTED_QUEUES = [
  WORKERHOLIC_QUEUE_NAMESPACE + FIRST_BALANCER_TEST_QUEUE,
  WORKERHOLIC_QUEUE_NAMESPACE + SECOND_BALANCER_TEST_QUEUE,
  WORKERHOLIC_QUEUE_NAMESPACE + THIRD_BALANCER_TEST_QUEUE,
  WORKERHOLIC_QUEUE_NAMESPACE + FOURTH_BALANCER_TEST_QUEUE
]

describe Workerholic::WorkerBalancer do
  let(:storage) { Workerholic::Storage::RedisWrapper.new }
  let(:redis) { Redis.new(url: Workerholic::REDIS_URL) }
  let(:workers) do
    Array.new(25).map { Workerholic::Worker.new }
  end

  it 'fetches queues' do
    100.times do |n|
      FirstJobBalancerTest.new.perform_async('first string', n)
      SecondJobBalancerTest.new.perform_async('second string', n)
      ThirdJobBalancerTest.new.perform_async('third string', n)
      FourthJobBalancerTest.new.perform_async('fourth string', n)
    end

    allow(Workerholic::WorkerBalancer.new).to receive(:fetch_queues).and_return(TESTED_QUEUES)

    balancer = Workerholic::WorkerBalancer.new(workers: [])

    expect(balancer.queues.map(&:name)).to match_array(TESTED_QUEUES)
  end

  context 'auto-balancing workers distribution' do
    it 'does not throw an error when there are no queues' do
      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.auto_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq({})
    end

    it 'correctly distributes workers for 1 queue' do
      100.times do |n|
        FirstJobBalancerTest.new.perform_async('first string', n)
      end
      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.auto_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq({ TESTED_QUEUES[0] => 25 })
    end

    it 'correctly distributes workers for 2 queues with equivalent loads' do
      100.times do |n|
        FirstJobBalancerTest.new.perform_async('first string', n)
        SecondJobBalancerTest.new.perform_async('second string', n)
      end
      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.auto_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq(
        {
          TESTED_QUEUES[0] => 12,
          TESTED_QUEUES[1] => 13
        }
      )
    end

    it 'correctly distributes workers for 2 queues with uneven loads' do
      100.times do |n|
        FirstJobBalancerTest.new.perform_async('first string', n)
      end

      200.times do |n|
        SecondJobBalancerTest.new.perform_async('second string', n)
      end

      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.auto_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq(
        {
          TESTED_QUEUES[0] => 9,
          TESTED_QUEUES[1] => 16
        }
      )
    end

    it 'correctly distributes workers for 3 queues with uneven loads' do
      95.times do |n|
        FirstJobBalancerTest.new.perform_async('first string', n)
        SecondJobBalancerTest.new.perform_async('second string', n)
      end

      110.times do |n|
        ThirdJobBalancerTest.new.perform_async('third string', n)
      end

      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.auto_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq(
        {
          TESTED_QUEUES[0] => 8,
          TESTED_QUEUES[1] => 8,
          TESTED_QUEUES[2] => 9
        }
      )
    end

    it 'correctly distributes workers for 4 queues with uneven loads' do
      100.times do |n|
        FirstJobBalancerTest.new.perform_async('first string', n)
        SecondJobBalancerTest.new.perform_async('second string', n)
      end

      200.times do |n|
        ThirdJobBalancerTest.new.perform_async('third string', n)
        FourthJobBalancerTest.new.perform_async('fourth string', n)
      end
      FourthJobBalancerTest.new.perform_async('fourth string', 201)

      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.auto_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq(
        {
          TESTED_QUEUES[0] => 4,
          TESTED_QUEUES[1] => 4,
          TESTED_QUEUES[2] => 8,
          TESTED_QUEUES[3] => 9
        }
      )
    end
  end

  context 'evenly-balancing workers distribution' do
    it 'does not throw an error when there are no queues' do
      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.evenly_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq({})
    end

    it 'correctly distributes workers for 1 queue' do
      100.times do |n|
        FirstJobBalancerTest.new.perform_async('first string', n)
      end
      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.evenly_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq({ TESTED_QUEUES[0] => 25 })
    end

    it 'correctly distributes workers for 2 queues with equivalent loads' do
      100.times do |n|
        FirstJobBalancerTest.new.perform_async('first string', n)
        SecondJobBalancerTest.new.perform_async('second string', n)
      end
      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.evenly_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq(
        {
          TESTED_QUEUES[0] => 12,
          TESTED_QUEUES[1] => 13
        }
      )
    end

    it 'correctly distributes workers for 2 queues with uneven loads' do
      100.times do |n|
        FirstJobBalancerTest.new.perform_async('first string', n)
      end

      200.times do |n|
        SecondJobBalancerTest.new.perform_async('second string', n)
      end

      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.evenly_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq(
        {
          TESTED_QUEUES[0] => 12,
          TESTED_QUEUES[1] => 13
        }
      )
    end

    it 'correctly distributes workers for 3 queues with uneven loads' do
      95.times do |n|
        FirstJobBalancerTest.new.perform_async('first string', n)
        SecondJobBalancerTest.new.perform_async('second string', n)
      end

      110.times do |n|
        ThirdJobBalancerTest.new.perform_async('third string', n)
      end

      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.evenly_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq(
        {
          TESTED_QUEUES[0] => 8,
          TESTED_QUEUES[1] => 8,
          TESTED_QUEUES[2] => 9
        }
      )
    end

    it 'correctly distributes workers for 4 queues with uneven loads' do
      100.times do |n|
        FirstJobBalancerTest.new.perform_async('first string', n)
        SecondJobBalancerTest.new.perform_async('second string', n)
      end

      200.times do |n|
        ThirdJobBalancerTest.new.perform_async('third string', n)
        FourthJobBalancerTest.new.perform_async('fourth string', n)
      end
      FourthJobBalancerTest.new.perform_async('fourth string', 201)

      wb = Workerholic::WorkerBalancer.new(workers: workers, auto: true)

      wb.evenly_balanced_workers_distribution

      expect(wb.current_workers_count_per_queue).to eq(
        {
          TESTED_QUEUES[0] => 6,
          TESTED_QUEUES[1] => 6,
          TESTED_QUEUES[2] => 6,
          TESTED_QUEUES[3] => 7
        }
      )
    end
  end
end

