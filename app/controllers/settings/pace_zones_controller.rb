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
        redirect_to settings_pace_zones_path, notice: "Zone mise à jour."
      else
        @zones = current_user.pace_zones.ordered
        render :index, status: :unprocessable_content
      end
    end

    def generate
      PaceZone.generate_defaults(current_user)
      redirect_to settings_pace_zones_path, notice: "Zones d'allure générées."
    end

    private

    def zone_params
      params.require(:pace_zone).permit(:name, :min_pace_seconds_per_km, :max_pace_seconds_per_km, :color)
    end
  end
end
