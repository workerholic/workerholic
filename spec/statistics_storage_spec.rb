require_relative 'spec_helper'

describe Workerholic::StatsStorage do
  let(:storage) { Workerholic::Storage::RedisWrapper.new }
  let(:stats_namespace) { 'workerholic:stats' }

  it 'saves job stats' do
    job = Workerholic::JobWrapper.new(klass: SimpleJobTest, arguments: ['test job'])

    job_hash = job.to_hash
    job_hash[:klass] = job_hash[:klass].to_s
    job_hash[:wrapper] = nil

    local_namespace = ":completed_jobs:#{job.klass.to_s}"

    Workerholic::StatsStorage.save_job('completed_jobs', job)

    namespace = stats_namespace + local_namespace
    serialized_stats = storage.get_all_elements_from_list(namespace).first
    deserialized_stats = Workerholic::JobSerializer.deserialize_stats(serialized_stats)

    expect(storage.list_length(namespace)).to eq 1
    expect(deserialized_stats).to eq job_hash
  end

  it 'saves process memory usage' do
    Workerholic::StatsStorage.save_processes_memory_usage

    namespace = stats_namespace + ':memory:processes'
    process_data = storage.hash_get_all(namespace)

    expect(storage.hash_get(namespace, process_data.keys.first)).to eq process_data.values.first
  end

  it 'cleans previous metrics records' do
    Workerholic::StatsStorage.delete_memory_stats

    namespace = stats_namespace + ':memory:processes'

    expect(storage.hash_get_all(namespace).empty?).to be true
  end
end
