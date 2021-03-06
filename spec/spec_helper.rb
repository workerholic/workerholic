# $LOAD_PATH << __dir__ + '/../lib/'

$TESTING = true

require 'workerholic'
require 'workerholic/adapters/active_job_adapter'

require_relative 'helpers/helper_methods'
require_relative 'helpers/job_tests'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before do
    Redis.new(url: Workerholic::REDIS_URL).flushdb
  end
end
