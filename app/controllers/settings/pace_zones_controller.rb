# frozen_string_literal: true

module Settings
  class PaceZonesController < ApplicationController
    def index
      @zones = current_user.pace_zones.ordered
    end

    def edit
      @zone = current_user.pace_zones.find(params[:id])
    end

    def update
      @zone = current_user.pace_zones.find(params[:id])

      if @zone.update(zone_params)
        redirect_to settings_pace_zones_path, notice: t("notices.settings.zone_updated")
      else
        @zones = current_user.pace_zones.ordered
        render :index, status: :unprocessable_content
      end
    end

    def generate
      PaceZone.generate_defaults(current_user)
      redirect_to settings_pace_zones_path, notice: t("notices.settings.pace_zones_generated")
    end

    private

    def zone_params
      params.expect(pace_zone: [:name, :min_pace_seconds_per_km, :max_pace_seconds_per_km, :color])
    end
  end
end
