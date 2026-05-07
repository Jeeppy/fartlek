# frozen_string_literal: true

module Strava
  class SyncService
    MAX_PAGES = 10
    PER_PAGE = 100

    attr_reader :credential

    def initialize(user)
      @credential = user.strava_credential
    end

    def call
      credential.refresh_if_expired!
      page = 1

      loop do
        activities = fetch_activities(page)
        break if activities.empty? || page > MAX_PAGES

        activities.each { |data| import_activity(data) }
        break if activities.size < PER_PAGE

        page += 1
      end
      credential.update!(last_sync_at: Time.current)
    rescue Strava::Client::RateLimitError
      Rails.logger.warn("Strava rate limit hit. Retrying in 15 minutes.")
      StravaSyncJob.set(wait: 15.minutes).perform_later(credential.user_id)
    end

    private

    def client
      @client ||= Strava::Client.new(credential)
    end

    def fetch_activities(page)
      params = { per_page: PER_PAGE, page: page }
      params[:after] = credential.last_sync_at.to_i if credential.last_sync_at
      client.activities(params)
    end

    def import_activity(data)
      return if activity_exists?(data["id"])
      return if unsupported_sport?(data["type"])

      detail = client.activity(data["id"])
      mapped = Strava::ActivityMapper.new(credential.user, detail).call

      persist_activity(mapped)
    end

    def activity_exists?(strava_id)
      Activity.exists?(user: credential.user, strava_id: strava_id)
    end

    def unsupported_sport?(type)
      Strava::ActivityMapper.map_sport(type).nil?
    end

    def persist_activity(mapped)
      laps = mapped.delete(:laps)
      activity = credential.user.activities.create!(mapped)
      create_laps(activity, laps)
      auto_match_planned(activity)
      AiActivityAnalysisJob.perform_later(activity.id)
    end

    def create_laps(activity, laps)
      return if laps.nil?

      laps.each { |lap_data| activity.activity_laps.create!(lap_data) }
    end

    def auto_match_planned(activity)
      planned = credential.user.planned_sessions
                          .where(date: activity.performed_at.to_date, sport: activity.sport, completed: false)
                          .first

      return unless planned

      planned.update!(activity: activity, completed: true)
      activity.update!(title: planned.title)
    end
  end
end
