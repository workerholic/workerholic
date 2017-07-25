$LOAD_PATH << __dir__ + '/../lib/'

require 'workerholic'

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
end
