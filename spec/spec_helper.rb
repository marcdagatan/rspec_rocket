require "rspec"
require "rspec/expectations"
require "rspec_rocket"
require "simplecov"
# Spec Helper file for RSpec.
# Loads the `rspec_rocket` gem and sets up RSpec configuration.
SimpleCov.start

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # This ensures a clean state before each test
  config.before do
    RSpecRocket.reset_configuration
  end
end

RSpecRocket.configure do |config|
  config.processors = 4
  config.verbose = true
end
