source 'https://rubygems.org'

ruby '3.4.1'

gem 'rails', '~> 8.1.2'

# Database
gem 'pg', '~> 1.5'

# Web server
gem 'puma', '>= 6.0'

# Caching / Jobs / Websocket
gem 'solid_cache'
gem 'solid_queue'
gem 'solid_cable'

# Redis
gem 'redis', '~> 5.0'
gem 'redis-client', '~> 0.22'
gem 'sidekiq', '~> 8.0'
gem 'sidekiq-cron', '~> 1.3'
gem 'sidekiq-status', '~> 2.0'

# money
gem 'money-rails'

# JSON Serialization
gem 'active_model_serializers', '~> 0.10.13'

# search
gem 'elasticsearch-model', '~> 8.0'
gem 'elasticsearch-rails', '~> 8.0'

# CORS
gem 'rack-cors'

# Dependency Injection / Service Objects
gem 'dry-system', '~> 0.23'
gem 'dry-transaction', '~> 0.13'
gem 'dry-validation', '~> 1.7'

# Background jobs (if you move from solid_queue)
gem 'sidekiq', '~> 8.0'

# Environment variables
gem 'dotenv-rails'

# Logging improvements
gem 'lograge'

# Monitoring / metrics
gem 'prometheus-client'

# Image processing
gem 'image_processing', '~> 1.2'

# Boot optimization
gem 'bootsnap', require: false

# Docker deployment
gem 'kamal', require: false

# Puma acceleration
gem 'thruster', require: false

# Timezone support (Windows)
gem 'tzinfo-data', platforms: %i[windows jruby]

# environment constants as yml
gem 'figaro'

gem 'foreman'


group :development, :test do
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  gem 'rspec-rails', '~> 7.0'
  gem 'factory_bot_rails'
  gem 'faker', '~> 3.1'

  # Code quality
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails-omakase', require: false

  # Security
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false

  gem 'pry-rails'
  gem 'rspec-rails', '~> 7.0'
end


group :development do
  # Better errors
  gem 'better_errors'
  gem 'binding_of_caller'

  # Rails console helpers
  gem 'awesome_print'
end


group :test do
  gem 'shoulda-matchers', '~> 6.0'
  gem 'database_cleaner-active_record', '~> 2.2'
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.30'
  gem 'simplecov', require: false
end
