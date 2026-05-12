# frozen_string_literal: true

module Settings
  class StravaController < ApplicationController
    def show
      @credential = current_user.strava_credential
      @authorize_url = Strava::AuthService.authorize_url
    end

    def destroy
      current_user.strava_credential&.destroy
      redirect_to settings_strava_path, notice: t("notices.settings.strava_disconnected")
    end

    def sync
      if current_user.strava_credential
        StravaSyncJob.perform_later(current_user.id)
        redirect_to settings_strava_path, notice: t("notices.settings.strava_sync_started")
      else
        redirect_to settings_strava_path, alert: t("alerts.strava.not_connected")
      end
    end
  end
end
