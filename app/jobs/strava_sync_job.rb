# frozen_string_literal: true

class StravaSyncJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    return unless user.strava_credential

    Strava::SyncService.new(user).call
  end
end
