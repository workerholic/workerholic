require_relative 'spec_helper'
require_relative '../lib/job_retry'

describe Workerholic::JobRetry do
  it 'increments number of retries'
  it 'schedules job by incrementing by 5 more seconds for every new retry'
  it 'pushes job inside "workerholic:scheduled_jobs" sorted set'
  it 'discards job if number of retries is greater than 5'
end
