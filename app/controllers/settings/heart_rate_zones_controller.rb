# frozen_string_literal: true

module Settings
  class HeartRateZonesController < ApplicationController
    def index
      @zones = current_user.heart_rate_zones.ordered
    end

    def edit
      @zone = current_user.heart_rate_zones.find(params[:id])
    end

    def update
      @zone = current_user.heart_rate_zones.find(params[:id])

      if @zone.update(zone_params)
        redirect_to settings_heart_rate_zones_path, notice: "Zone mise à jour."
      else
        @zones = current_user.heart_rate_zones.ordered
        render :index, status: :unprocessable_content
      end
    end

    def generate
      HeartRateZone.generate_defaults(current_user)
      redirect_to settings_heart_rate_zones_path,
                  notice: "Zones FC générées depuis FC max estimée (#{current_user.estimated_max_hr} bpm)."
    end

    private

    def zone_params
      params.require(:heart_rate_zone).permit(:name, :min_bpm, :max_bpm, :color)
    end
  end
end
