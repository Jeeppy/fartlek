# frozen_string_literal: true

source "https://rubygems.org"

# ─── Core ─────────────────────────────────────────────
gem "bootsnap", require: false
gem "pg", "~> 1.1"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.1.3"

# ─── Frontend ─────────────────────────────────────────
gem "importmap-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "turbo-rails"

# ─── Auth ─────────────────────────────────────────────
gem "devise", "~> 4.9"

# ─── Background jobs & Redis ─────────────────────────
gem "connection_pool", "~> 2.4"
gem "hiredis-client", "~> 0.28.0"
gem "redis", "~> 5.3"
gem "sidekiq", "~> 7.3"

# ─── HTTP & APIs ──────────────────────────────────────
gem "faraday", "~> 2.12"

# ─── Utils ────────────────────────────────────────────
gem "chartkick", "~> 5.1"
gem "groupdate", "~> 6.5"
gem "image_processing", "~> 1.2"
gem "pagy", "~> 43.5"

# ─── Deploy ───────────────────────────────────────────
gem "kamal", require: false
gem "thruster", require: false

# ─── Platform ─────────────────────────────────────────
gem "tzinfo-data", platforms: [:windows, :jruby]

# ─── Development & Test ──────────────────────────────
group :development, :test do
  gem "debug", platforms: [:mri, :windows], require: "debug/prelude"

  # Test
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.5"
  gem "rspec-rails", "~> 8.0"

  # Lint
  gem "rubocop", "~> 1.86", require: false
  gem "rubocop-factory_bot", "~> 2.28", require: false
  gem "rubocop-performance", "~> 1.26", require: false
  gem "rubocop-rails", "~> 2.34", require: false
  gem "rubocop-rspec", "~> 3.9", require: false

  # Security
  gem "brakeman", require: false
  gem "bundler-audit", require: false
end

# ─── Development only ────────────────────────────────
group :development do
  gem "web-console"
end

# ─── Test only ────────────────────────────────────────
group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 6.4"
  gem "simplecov", "~> 0.22.0", require: false
  gem "vcr", "~> 6.3"
  gem "webmock", "~> 3.24"
end

gem "haml-rails", "~> 3.0"

gem "haml_lint", "~> 0.73.0", groups: [:development, :test], require: false

gem "pry", "~> 0.16.0"
