# frozen_string_literal: true

module Export
  class ActivitiesController < ApplicationController
    def index
      activities = current_user.activities.chronological

      activities = activities.where(performed_at: params[:from].to_date.beginning_of_day..) if params[:from].present?

      activities = activities.where(performed_at: ..params[:to].to_date.end_of_day) if params[:to].present?

      activities = activities.by_sport(params[:sport]) if params[:sport].present?

      data = Export::ActivityJsonExporter.export_collection(activities)

      send_data data.to_json,
                filename: "fartlek_export_#{Date.current}.json",
                type: :json
    end
  end
end
