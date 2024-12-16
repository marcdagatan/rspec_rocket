require "database_cleaner/active_record"
require "active_record"

module RSpecRocket
  # Manages database state for parallel tests.
  #
  # Supports transaction or separate databases strategies.
  class DBManager
    # @param strategy [Symbol] :transaction or :separate
    # @param processors [Integer]
    # @param databases [Array<String>] for separate strategy
    def initialize(strategy, processors, databases)
      @strategy = strategy
      @processors = processors
      @databases = databases
      @connections = {}
      @database_enabled = database_present?
    end

    # Sets up the database according to strategy.
    # @return [void]
    def setup
      return unless @database_enabled

      puts("Setting up database strategy: #{@strategy}")
      if transaction_strategy?
        DatabaseCleaner.strategy = :transaction
        DatabaseCleaner.clean_with(:truncation)
      elsif separate_strategy?
        setup_separate_databases
      end
    end

    # Prepares thread for DB operations.
    # @return [void]
    def before_each_thread
      return unless @database_enabled && transaction_strategy?

      DatabaseCleaner.start
    end

    # Cleans thread DB state after done.
    # @return [void]
    def after_each_thread
      return unless @database_enabled && transaction_strategy?

      DatabaseCleaner.clean
    end

    # Tears down separate databases.
    # @return [void]
    def teardown
      return unless @database_enabled && separate_strategy?

      puts("Tearing down separate databases...")
      @connections.each_value do |conn|
        ActiveRecord::Base.establish_connection(conn)
        ActiveRecord::Base.connection.drop_database(conn["database"])
      end
    end

    private

    # @return [Boolean] true if DB is present
    def database_present?
      ActiveRecord::Base.connection
      true
    rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
      puts("No database detected. Skipping DB-related setup.")
      false
    end

    # @return [Boolean]
    def transaction_strategy?
      @strategy == :transaction
    end

    # @return [Boolean]
    def separate_strategy?
      @strategy == :separate
    end

    # Sets up separate databases.
    # @return [void]
    def setup_separate_databases
      @databases.each_with_index do |db_name, i|
        db_config = ActiveRecord::Base.configurations.find_db_config("test").configuration_hash
        db_config["database"] = db_name
        ActiveRecord::Base.establish_connection(db_config)
        begin
          ActiveRecord::Base.connection.create_database(db_name)
          puts("Database created: #{db_name}")
        rescue StandardError
          puts("Failed to create database: #{db_name}, might already exist.")
        end
        @connections[i] = db_config
      end
    end
  end
end
