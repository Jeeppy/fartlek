# frozen_string_literal: true

module Strava
  class CallbacksController < ApplicationController
    def create
      code = params[:code]

      if code.nil?
        redirect_to settings_strava_path, alert: "Authorization failed. No code provided."
      else
        tokens = Strava::AuthService.exchange_token(code)
        current_user.create_strava_credential!(
          strava_athlete_id: tokens["athlete"]["id"],
          access_token: tokens["access_token"],
          refresh_token: tokens["refresh_token"],
          expires_at: Time.zone.at(tokens["expires_at"])
        )
        StravaSyncJob.perform_later(current_user.id)
        redirect_to settings_strava_path, notice: "Strava account connected successfully. Syncing"
      end
    end
  end
end
