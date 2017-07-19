require_relative 'spec_helper'

require_relative '../lib/job_scheduler'
require_relative './helpers/job_tests.rb'

describe Workerholic::JobScheduler do
  context 'with non-empty set' do
    it 'checks the time for scheduled job inside sorted set' do
    end
    it 'fetches a job from a sorted set'
    it 'enqueues due job to a main named queue'
    it 'checks the sorted set every N seconds'
  end
end
