# frozen_string_literal: true

module Settings
  class StravaController < ApplicationController
    def show
      @credential = current_user.strava_credential
      @authorize_url = Strava::AuthService.authorize_url
    end

    def destroy
      current_user.strava_credential&.destroy
      redirect_to settings_strava_path, notice: "Strava déconnecté."
    end

    def sync
      if current_user.strava_credential
        StravaSyncJob.perform_later(current_user.id)
        redirect_to settings_strava_path, notice: "Synchronisation lancée."
      else
        redirect_to settings_strava_path, alert: "Aucun compte Strava connecté."
      end
    end
  end
end
