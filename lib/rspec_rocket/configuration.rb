module RSpecRocket
  # Holds configuration for rspec_rocket.
  #
  # @attr_accessor [Integer] processors number of processors
  # @attr_accessor [String] spec_dir directory containing specs (default: "spec")
  # @attr_accessor [Symbol] db_strategy (:transaction or :separate)
  # @attr_accessor [Array<String>] databases for separate strategy
  # @attr_accessor [Symbol] log_level logging level (:debug, :info, :warn, :error)
  # @attr_accessor [Boolean] verbose enable verbose logging
  class Configuration
    attr_accessor :processors, :spec_dir, :db_strategy, :databases, :log_level, :verbose

    def initialize
      @processors = 4
      @spec_dir = "spec"
      @db_strategy = :transaction
      @databases = []
      @log_level = :info
      @verbose = false
    end
  end
end
