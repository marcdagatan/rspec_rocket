require "logger"

module RSpecRocket
  # Centralized logging for RSpecRocket.
  module Logger
    @logger = nil
    @mutex = Mutex.new

    class << self
      # Configures the logger.
      #
      # @param level [Symbol] log level (:debug, :info, :warn, :error)
      # @param output [IO] output stream (default: $stdout)
      # @return [void]
      def configure(level: :info, output: $stdout)
        @mutex.synchronize do
          @logger = ::Logger.new(output)
          @logger.level = level_from_symbol(level)
          @logger.formatter = proc do |severity, datetime, _progname, msg|
            "#{datetime.strftime("%Y-%m-%d %H:%M:%S")} [#{severity}] #{msg}\n"
          end
        end
      end

      # @return [Logger] the logger instance
      def logger
        @logger || configure
        @logger
      end

      # Logs an info message.
      # @param msg [String] The message to log
      def info(msg)
        sync_log { logger.info(msg) }
      end

      # Logs a warn message.
      # @param msg [String] The message to log
      def warn(msg)
        sync_log { logger.warn(msg) }
      end

      # Logs an error message.
      # @param msg [String] The message to log
      def error(msg)
        sync_log { logger.error(msg) }
      end

      # Logs a debug message.
      # @param msg [String] The message to log
      def debug(msg)
        sync_log { logger.debug(msg) }
      end

      private

      # Converts symbol to logger level.
      #
      # @param sym [Symbol]
      # @return [Integer] corresponding Logger level constant
      def level_from_symbol(sym)
        case sym
        when :debug then ::Logger::DEBUG
        when :warn then ::Logger::WARN
        when :error then ::Logger::ERROR
        else ::Logger::INFO
        end
      end

      # Synchronizes log calls using a mutex to prevent concurrent writing issues.
      def sync_log(&block)
        @mutex.synchronize(&block)
      end
    end
  end
end
