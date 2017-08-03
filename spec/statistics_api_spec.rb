require_relative 'spec_helper'

describe Workerholic::StatsAPI do
  let(:storage) { Workerholic::Storage::RedisWrapper.new }
  let(:stats_namespace) { 'workerholic:stats' }
  let(:job) { Workerholic::JobWrapper.new(klass: SimpleJobTest, arguments: ['test job']) }

  it 'returns full statistics for category' do
    namespace = "workerholic:stats:completed_jobs:#{job.klass.to_s}"
    Workerholic::StatsStorage.save_job('completed_jobs', job)

    serialized_job = storage.get_all_elements_from_list(namespace).first
    deserialized_job = Workerholic::JobSerializer.deserialize_stats(serialized_job)

    stats_api_result = Workerholic::StatsAPI.job_statistics(category: 'completed_jobs')
    first_job_stat = stats_api_result.first[0]

    expect(first_job_stat).to eq deserialized_job
  end

  it 'returns jobs count statistics for category'

  it 'returns scheduled jobs statistics' do
    namespace = 'workerholic:scheduled_jobs'
    sorted_set = Workerholic::SortedSet.new(namespace)

    job.execute_at = Time.now.to_f + 10
    job_hash = job.to_hash
    job_hash[:klass] = job.klass.to_s
    job_hash[:wrapper] = nil

    sorted_set.add(Workerholic::JobSerializer.serialize(job_hash), job_hash[:execute_at])

    serialized_job = storage.sorted_set_members(namespace).first
    deserialized_job = Workerholic::JobSerializer.deserialize_stats(serialized_job)

    stats_api_result = Workerholic::StatsAPI.scheduled_jobs

    first_scheduled_job = stats_api_result.first

    expect(first_scheduled_job).to eq deserialized_job
  end

  it 'returns scheduled jobs count'
end
