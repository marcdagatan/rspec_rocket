require "optparse"

module RSpecRocket
  # CLI interface for rspec_rocket.
  class CLI
    class << self
      # Starts the CLI, parsing options and running tests.
      #
      # @return [void]
      def start
        RSpecRocket.reset_configuration

        spec_files, rspec_options, cli_options = parse_arguments(ARGV)
        apply_cli_options(cli_options)

        # If user didn't provide spec files, use the configured spec_dir
        spec_files = Dir["#{RSpecRocket.configuration.spec_dir}/**/*_spec.rb"] if spec_files.empty?

        if spec_files.empty?
          puts "No spec files found"
          exit(1)
        end

        RSpecRocket::Runner.run(
          spec_files: spec_files,
          processors: RSpecRocket.configuration.processors,
          db_strategy: RSpecRocket.configuration.db_strategy,
          databases: RSpecRocket.configuration.databases,
          verbose: RSpecRocket.configuration.verbose,
          rspec_options: rspec_options
        )
      end

      private

      # Parses the command line arguments, separating CLI options, spec files, and RSpec options.
      #
      # Format:
      #   rspec-rocket [CLI options / spec files / directories] [-- rspec_options]
      #
      # @param args [Array<String>] the original ARGV
      # @return [Array<Array<String>, Array<String>, Hash]] [spec_files, rspec_options, cli_options]
      def parse_arguments(args) # rubocop:disable Metrics/AbcSize
        # Split arguments at `--`. Everything after is for RSpec.
        double_dash_index = args.index("--")
        if double_dash_index
          rspec_options = args[(double_dash_index + 1)..]
          primary_args = args[0...double_dash_index]
        else
          rspec_options = []
          primary_args = args.dup
        end

        # Extract CLI options using OptionParser
        # Temporarily hold the CLI options in a hash
        cli_options = {}
        parser = OptionParser.new do |opts|
          opts.banner = "Usage: rspec-rocket [options] [files or dirs] [-- rspec options]"

          opts.on("-p", "--processors N", Integer, "Number of processors") { |v| cli_options[:processors] = v }
          opts.on("--db-strategy STRATEGY", "DB strategy: transaction or separate") do |v|
            cli_options[:db_strategy] = v.to_sym
          end
          opts.on("--verbose", "Enable verbose logging") { cli_options[:verbose] = true }
        end

        # Parse only known CLI options. Unrecognized arguments remain.
        remaining = []
        begin
          parser.order!(primary_args) { |arg| remaining << arg }
        rescue OptionParser::InvalidOption => e
          # If invalid option, treat it as a spec file or directory
          remaining += e.args
        end

        # remaining arguments at this point should be spec files or directories
        spec_files = extract_spec_files(remaining)

        [spec_files, rspec_options, cli_options]
      end

      # Extract spec files from given arguments
      # Treat arguments ending with `_spec.rb` or directories as valid spec sources
      #
      # @param args [Array<String>] arguments after parsing known CLI options
      # @return [Array<String>] list of spec files
      def extract_spec_files(args)
        files = []
        args.each do |arg|
          if File.directory?(arg)
            # If it's a directory, take all specs from it
            files.concat(Dir["#{arg}/**/*_spec.rb"])
          elsif arg.end_with?("_spec.rb") && File.exist?(arg)
            files << arg
          end
        end
        files
      end

      # Applies CLI options to configuration.
      #
      # @param options [Hash]
      # @return [void]
      def apply_cli_options(options)
        RSpecRocket.configure do |config|
          config.processors = options[:processors] if options.key?(:processors)
          config.db_strategy = options[:db_strategy] if options.key?(:db_strategy)
          config.verbose = options[:verbose] if options.key?(:verbose)
        end
      end
    end
  end
end
