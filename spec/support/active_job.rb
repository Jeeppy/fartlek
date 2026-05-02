# frozen_string_literal: true

RSpec.configure do |config|
  config.include ActiveJob::TestHelper, type: :request

  config.before(:each, type: :request) do
    ActiveJob::Base.queue_adapter = :test
  end
end
