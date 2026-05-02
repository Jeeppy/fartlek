# frozen_string_literal: true

module Strava
  class SyncService
    attr_reader :credential

    def initialize(user)
      @credential = user.strava_credential
    end

    def call
      credential.refresh_if_expired!
      fetch_activities.each { |data| import_activity(data) }
      credential.update!(last_sync_at: Time.current)
    end

    private

    def client
      @client ||= Strava::Client.new(credential)
    end

    def fetch_activities
      client.activities(per_page: 30, after: credential.last_sync_at.to_i)
    end

    def import_activity(data)
      return if Activity.exists?(user: credential.user, strava_id: data["id"])

      sport = Strava::ActivityMapper.map_sport(data["type"])
      return if sport.nil?

      detail = client.activity(data["id"])
      mapped = Strava::ActivityMapper.new(credential.user, detail).call
      laps = mapped.delete(:laps)
      activity = credential.user.activities.create!(mapped)
      create_laps(activity, laps)
    end

    def create_laps(activity, laps)
      return if laps.nil?

      laps.each do |lap_data|
        activity.activity_laps.create!(lap_data)
      end
    end
  end
end
