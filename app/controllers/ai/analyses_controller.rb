# frozen_string_literal: true

module Ai
  class AnalysesController < ApplicationController
    def create
      @activity = current_user.activities
                              .includes(:activity_laps, :activity_tags, :equipment, :planned_session)
                              .find(params[:activity_id])

      begin
        ::Ai::ActivityAnalyzer.new(@activity, current_user).call
        redirect_to activity_path(@activity), notice: "Analyse générée."
      rescue ::Ai::BaseService::ApiError => e
        redirect_to activity_path(@activity), alert: "Erreur API : #{e.message}"
      end
    end
  end
end
