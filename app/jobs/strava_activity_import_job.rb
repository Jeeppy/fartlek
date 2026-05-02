# frozen_string_literal: true

class StravaActivityImportJob < ApplicationJob
  queue_as :default

  def perform(user_id, strava_id)
    user = User.find(user_id)
    return unless user.strava_credential
    return if user.activities.exists?(strava_id: strava_id)

    import_activity(user, strava_id)
  end

  private

  def import_activity(user, strava_id)
    credential = user.strava_credential
    credential.refresh_if_expired!

    detail = Strava::Client.new(credential).activity(strava_id)
    mapped = Strava::ActivityMapper.new(user, detail).call
    return if mapped[:sport].nil?

    create_with_laps(user, mapped)
  end

  def create_with_laps(user, mapped)
    laps = mapped.delete(:laps)
    activity = user.activities.create!(mapped)
    laps&.each { |lap_data| activity.activity_laps.create!(lap_data) }
  end
end
