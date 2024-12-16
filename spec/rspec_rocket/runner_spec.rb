# frozen_string_literal: true

require "spec_helper"
require "rspec/expectations"

# Minimal fake classes for RSpec structures
class FakeOrderedGroups
  def flat_map
    []
  end
end

RSpec.describe RSpecRocket::Runner do
  let(:spec_files) { ["spec/example_spec.rb"] }
  let(:processors) { 2 }
  let(:db_strategy) { :transaction }
  let(:databases) { [] }
  let(:verbose) { false }
  let(:rspec_options) { [] }

  let(:db_manager) do
    instance_double(RSpecRocket::DBManager, setup: nil, teardown: nil, before_each_thread: nil, after_each_thread: nil)
  end
  let(:logger) { class_spy(RSpecRocket::Logger) }
  let(:configuration_options) { instance_spy(RSpec::Core::ConfigurationOptions) }

  before do
    # Stub DBManager and Logger
    stub_const("RSpecRocket::Logger", logger)
    allow(RSpecRocket::DBManager).to receive(:new).and_return(db_manager)

    # Avoid message chain by stubbing ordered_example_groups directly
    ordered_groups = instance_double(FakeOrderedGroups)
    allow(ordered_groups).to receive(:flat_map).and_return([])
    allow(RSpec.world).to receive(:ordered_example_groups).and_return(ordered_groups)

    # Stub ConfigurationOptions creation
    allow(RSpec::Core::ConfigurationOptions).to receive(:new).and_return(configuration_options)

    # Default scenario: one passing example
    example = instance_double(RSpec::Core::Example)
    allow(example).to receive(:run).and_return(true)

    # Default: ordered_groups returns one example
    allow(ordered_groups).to receive(:flat_map).and_return([example])

    # Avoid parallel processors complexity
    allow(Parallel).to receive(:map).and_return([])
  end

  it "runs tests and sets up DB manager" do
    # Run code under test
    described_class.run(
      spec_files: spec_files,
      processors: processors,
      db_strategy: db_strategy,
      databases: databases,
      verbose: verbose,
      rspec_options: rspec_options
    )
    expect(RSpecRocket::DBManager).to have_received(:new).with(db_strategy, processors, databases)
  end

  it "applies rspec_options if given" do
    custom_options = ["--format", "documentation"]
    allow(RSpec::Core::ConfigurationOptions).to receive(:new).with(custom_options).and_return(configuration_options)

    described_class.run(
      spec_files: spec_files,
      processors: processors,
      db_strategy: db_strategy,
      databases: databases,
      verbose: verbose,
      rspec_options: custom_options
    )

    expect(RSpec::Core::ConfigurationOptions).to have_received(:new).with(custom_options)
  end

  context "when an example fails due to a failed expectation" do
    it "handles test failures" do
      failing_example = instance_double(RSpec::Core::Example)
      failing_example_group_class = Class.new
      allow(failing_example).to receive(:example_group).and_return(failing_example_group_class)
      allow(failing_example).to receive(:run).and_raise(RSpec::Expectations::ExpectationNotMetError, "Expected failure")

      # Override defaults for this test
      ordered_groups = instance_double(FakeOrderedGroups, flat_map: [failing_example])
      allow(RSpec.world).to receive(:ordered_example_groups).and_return(ordered_groups)
      allow(Parallel).to receive(:map).and_yield(failing_example).and_return([])

      allow(logger).to receive(:warn)

      described_class.run(
        spec_files: spec_files,
        processors: processors,
        db_strategy: db_strategy,
        databases: databases,
        verbose: verbose,
        rspec_options: rspec_options
      )

      expect(logger).to have_received(:warn).with(/Test failed:/)
    end
  end

  context "when an example raises an unexpected error" do
    it "handles unexpected errors" do
      error_example = instance_double(RSpec::Core::Example)
      error_example_group_class = Class.new
      allow(error_example).to receive(:example_group).and_return(error_example_group_class)
      allow(error_example).to receive(:run).and_raise(StandardError, "Unknown error")

      # Override defaults for this test
      ordered_groups = instance_double(FakeOrderedGroups, flat_map: [error_example])
      allow(RSpec.world).to receive(:ordered_example_groups).and_return(ordered_groups)
      allow(Parallel).to receive(:map).and_yield(error_example).and_return([])

      allow(logger).to receive(:error)

      described_class.run(
        spec_files: spec_files,
        processors: processors,
        db_strategy: db_strategy,
        databases: databases,
        verbose: verbose,
        rspec_options: rspec_options
      )

      expect(logger).to have_received(:error).with(/Unknown error/)
    end
  end
end
