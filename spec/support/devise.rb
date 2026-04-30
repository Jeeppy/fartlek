# frozen_string_literal: true

RSpec.configure do |config|
  config.include Warden::Test::Helpers
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  config.after { Warden.test_reset! }
end
