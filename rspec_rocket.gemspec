require_relative "lib/rspec_rocket/version"

Gem::Specification.new do |spec|
  spec.name = "rspec_rocket"
  spec.version = RspecRocket::VERSION
  spec.authors = ["Marc Lawrence U. Dagatan"]
  spec.email = ["marc.dagatan@gmail.com"]

  spec.summary = "Run RSpec tests in parallel with 🚀 speed!"
  spec.description = "Parallelize RSpec tests at the example level with built-in database handling."
  spec.homepage = "https://github.com/marcdagatan/rspec_rocket"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/marcdagatan/rspec_rocket"
  spec.metadata["changelog_uri"] = "https://github.com/marcdagatan/rspec_rocket/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["lib/**/*", "bin/**/*", "README.md"]

  spec.executables   = ["rspec-rocket"]
  spec.require_paths = ["lib"]

  spec.add_dependency "database_cleaner-active_record", "~> 2.0"
  spec.add_dependency "parallel", "~> 1.22.0"
  spec.add_dependency "rspec", "~> 3.0"

  # Supporting both Rails 6 and 7 means ActiveRecord and ActiveSupport ~>6.0 or ~>7.0
  # We’ll keep these open for either 6.x or 7.x.
  # If user doesn't use a DB, these won't be strictly necessary, but we assume presence for DB support.
  spec.add_dependency "activerecord", ">= 6.0", "< 8.0"
  spec.add_dependency "activesupport", ">= 6.0", "< 8.0"
end
