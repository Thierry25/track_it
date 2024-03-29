# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'json'
gem 'puma', '~>5'
gem 'roda', '~>3'

# Configuration
gem 'figaro', '~>1'
gem 'rake'

# Security
gem 'bundler-audit'
gem 'rbnacl', '~>7'

# Database
gem 'hirb'
gem 'sequel', '~>5'

group :production do
  gem 'pg'
end

# External Services
gem 'http'

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end

# Debugging
gem 'pry'
gem 'rack-test'

group :development do
  gem 'rerun'

   # Quality
  gem 'rubocop'
  gem 'rubocop-performance'

end

group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3'
end

# Coverage
gem 'simplecov'


# # Validation
# gem 'dry-struct', '~> 1.4'
# gem 'dry-types', '~> 1.5'

# # Networking
# gem 'http', '~> 5.0'

# # Testing
# gem 'minitest', '~> 5.0'
# gem 'minitest-rg', '~> 5.0'
# gem 'simplecov', '~> 0'
# gem 'vcr', '~> 6.0'
# gem 'webmock', '~> 3.0'

# # Utility Tools
# gem 'rake'

# # Code Quality
# gem 'flog'
# gem 'reek'
# gem 'rubocop'