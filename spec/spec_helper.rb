$LOAD_PATH << __dir__ + '/../lib/'

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
    Redis.new.del(TEST_QUEUE, ANOTHER_TEST_QUEUE, BALANCER_TEST_QUEUE, ANOTHER_BALANCER_TEST_QUEUE, TEST_SCHEDULED_SORTED_SET, HASH_TEST)
  end

  config.after do
    Redis.new.del(TEST_QUEUE, ANOTHER_TEST_QUEUE, BALANCER_TEST_QUEUE, ANOTHER_BALANCER_TEST_QUEUE, TEST_SCHEDULED_SORTED_SET, HASH_TEST)
  end
end
