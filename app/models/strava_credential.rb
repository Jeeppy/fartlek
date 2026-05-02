# frozen_string_literal: true

class StravaCredential < ApplicationRecord
  belongs_to :user

  validates :strava_athlete_id, presence: true
  validates :access_token, presence: true
  validates :refresh_token, presence: true
  validates :expires_at, presence: true
  validates :user_id, uniqueness: true

  def expired?
    expires_at < DateTime.now
  end

  def refresh_if_expired!
    return unless expired?

    tokens = Strava::AuthService.refresh_token(refresh_token)

    self.access_token = tokens["access_token"]
    self.refresh_token = tokens["refresh_token"]
    self.expires_at = Time.zone.at(tokens["expires_at"])
    save!
  end
end
