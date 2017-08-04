require_relative 'spec_helper'

describe Workerholic::StatsAPI do
  let(:storage) { Workerholic::Storage::RedisWrapper.new }
  let(:stats_namespace) { 'workerholic:stats' }
  let(:job) { Workerholic::JobWrapper.new(klass: SimpleJobTest, arguments: ['test job']) }

  it 'returns full statistics for category' do
    namespace = stats_namespace + ':completed_jobs:*'

    Workerholic::StatsStorage.save_job('completed_jobs', job)

    job_class = storage.get_keys_for_namespace(namespace).first

    serialized_job = storage.get_all_elements_from_list(job_class).first
    deserialized_job = Workerholic::JobSerializer.deserialize_stats(serialized_job)

    stats_api_result = Workerholic::StatsAPI.job_statistics(category: 'completed_jobs')
    first_job_stat = stats_api_result.first[0]

    expect(stats_api_result.size).to eq 1
    expect(first_job_stat).to eq deserialized_job
  end

  it 'returns jobs count statistics for category' do
    Workerholic::StatsStorage.save_job('completed_jobs', job)

    stats_api_result = Workerholic::StatsAPI.job_statistics(category: 'completed_jobs', count_only: true)
    stat_counter = stats_api_result.first

    expect(stat_counter).to eq [job.klass.to_s, 1]
  end

  context 'with scheduled job' do
    let(:namespace) { 'workerholic:scheduled_jobs' }

    before do
      sorted_set = Workerholic::SortedSet.new(namespace)

      job.execute_at = Time.now.to_f + 10
      job_hash = job.to_hash
      job_hash[:klass] = job.klass.to_s
      job_hash[:wrapper] = nil

      sorted_set.add(Workerholic::JobSerializer.serialize(job_hash), job_hash[:execute_at])
    end

    it 'returns scheduled jobs statistics' do
      serialized_job = storage.sorted_set_members(namespace).first
      deserialized_job = Workerholic::JobSerializer.deserialize_stats(serialized_job)

      stats_api_result = Workerholic::StatsAPI.scheduled_jobs

      first_scheduled_job = stats_api_result.first

      expect(first_scheduled_job).to eq deserialized_job
    end

    it 'returns scheduled jobs count' do
      stats_api_result = Workerholic::StatsAPI.scheduled_jobs(count_only: true)

      expect(stats_api_result).to eq 1
    end
  end

  it 'returns historical statistics for namespace' do
    category = 'completed_jobs'
    Workerholic::StatsStorage.update_historical_stats(category, job.klass.to_s)

    history_hash = Workerholic::StatsAPI.history_for_period(category: category, period: 1)

    expect(history_hash[:job_counts]).to match [1, 0]
  end
end
