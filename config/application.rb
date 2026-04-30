# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
Bundler.require(*Rails.groups)

module Fartlek
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: ["assets", "tasks"])
    config.generators.system_tests = nil

    # Active Job
    config.active_job.queue_adapter = :sidekiq
    config.active_job.queue_name_prefix = "fartlek"

    # Time zone
    config.time_zone = "Europe/Paris"

    # Locale
    config.i18n.default_locale = :fr
    config.i18n.available_locales = [:fr, :en]

    # Generators
    config.generators do |g|
      g.test_framework :rspec,
                       fixtures: false,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false
      g.template_engine :haml
    end
  end
end
