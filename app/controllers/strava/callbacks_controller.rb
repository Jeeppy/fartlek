# frozen_string_literal: true

module Strava
  class CallbacksController < ApplicationController
    def create
      return redirect_to settings_strava_path, alert: t("alerts.strava.no_code") unless params[:code]

      connect_strava(params[:code])
      redirect_to settings_strava_path, notice: t("notices.settings.strava_connected")
    end

    private

    def connect_strava(code)
      tokens = Strava::AuthService.exchange_token(code)
      current_user.create_strava_credential!(
        strava_athlete_id: tokens["athlete"]["id"],
        access_token: tokens["access_token"],
        refresh_token: tokens["refresh_token"],
        expires_at: Time.zone.at(tokens["expires_at"])
      )
      StravaSyncJob.perform_later(current_user.id)
    end
  end
end
