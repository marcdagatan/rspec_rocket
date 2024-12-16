require "rspec"
require "parallel"

module RSpecRocket
  # Runs RSpec tests in parallel at the example level.
  class Runner
    class << self
      # Runs the test suite in parallel.
      #
      # @param spec_files [Array<String>] the list of spec files to run
      # @param processors [Integer] number of processors
      # @param db_strategy [Symbol] db strategy (:transaction or :separate)
      # @param databases [Array<String>] list of databases for separate strategy
      # @param verbose [Boolean] verbose logging
      # @param rspec_options [Array<String>] additional RSpec CLI options
      # @return [void]
      def run(spec_files:, processors:, db_strategy:, databases:, verbose:, rspec_options:) # rubocop:disable Metrics/ParameterLists
        setup_rspec(spec_files, verbose, rspec_options)

        db_manager = DBManager.new(db_strategy, processors, databases)
        db_manager.setup

        examples = RSpec.world.ordered_example_groups.flat_map(&:examples)
        errors = Parallel.map(examples, in_processes: processors) do |example|
          run_example_in_isolation(example, db_manager)
        end

        db_manager.teardown
        report_errors(errors.compact)
      end

      private

      # Sets up RSpec with given spec files, verbosity, and RSpec options.
      #
      # @param spec_files [Array<String>]
      # @param verbose [Boolean]
      # @param rspec_options [Array<String>] additional RSpec CLI options
      # @return [void]
      def setup_rspec(spec_files, verbose, rspec_options)
        RSpec.reset

        unless rspec_options.empty?
          options = RSpec::Core::ConfigurationOptions.new(rspec_options)
          options.configure(RSpec.configuration)
        end

        RSpec.configuration.files_to_run = spec_files
        RSpec.configuration.load_spec_files
        puts("RSpec loaded.") if verbose
      end

      # Runs a single example in isolation.
      #
      # @param example [RSpec::Core::Example]
      # @param db_manager [DBManager]
      # @return [String, nil] error message or nil if success
      def run_example_in_isolation(example, db_manager)
        db_manager.before_each_thread
        example_group_instance = example.example_group.new
        example.run(example_group_instance, RSpec.configuration.reporter)
      rescue RSpec::Expectations::ExpectationNotMetError => e
        puts("Test failed: #{e.message}")
        "Failure: #{e.message}"
      rescue StandardError => e
        puts("Error: #{e.message}")
        "Error: #{e.message}"
      ensure
        db_manager.after_each_thread
      end

      # Reports errors found after tests.
      #
      # @param errors [Array<String>]
      # @return [void]
      def report_errors(errors)
        return if errors.empty?

        puts("Test errors found:")
        errors.each { |err| puts(err) }
      end
    end
  end
end
