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
    namespace = stats_namespace + local_namespace

    Workerholic::StatsStorage.save_job('completed_jobs', job)

    serialized_stats = storage.sorted_set_all_members(namespace).first

    expect(storage.sorted_set_size(namespace)).to eq 1
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
