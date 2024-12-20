# RSpecRocket runs RSpec tests in parallel at the example (it) level.
# It integrates with RSpec and can handle database strategies.
#
# Supports Rails 6 and 7 (ActiveRecord, ActiveSupport).
#
# @example Basic usage:
#   rspec-rocket
#
# @example Configuring processors:
#   RSpecRocket.configure do |config|
#     config.processors = 8
#   end

require_relative "rspec_rocket/version"
require_relative "rspec_rocket/configuration"
require_relative "rspec_rocket/db_manager"
require_relative "rspec_rocket/runner"
require_relative "rspec_rocket/cli"

module RSpecRocket
  class << self
    attr_accessor :configuration

    # Configures RSpecRocket using a block.
    #
    # @yieldparam [Configuration] config
    # @return [void]
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    # Resets configuration to defaults.
    #
    # @return [void]
    def reset_configuration
      self.configuration = Configuration.new
    end
  end
end
