# frozen_string_literal: true

module Export
  class ActivitiesController < ApplicationController
    def index
      data = Export::ActivityJsonExporter.export_collection(filtered_activities)
      send_data data.to_json,
                filename: "fartlek_export_#{Date.current}.json",
                type: :json
    end

    private

    def filtered_activities
      activities = current_user.activities.chronological
      activities = filter_from(activities)
      activities = filter_to(activities)
      filter_sport(activities)
    end

    def filter_from(activities)
      return activities if params[:from].blank?

      activities.where(performed_at: params[:from].to_date.beginning_of_day..)
    end

    def filter_to(activities)
      return activities if params[:to].blank?

      activities.where(performed_at: ..params[:to].to_date.end_of_day)
    end

    def filter_sport(activities)
      return activities if params[:sport].blank?

      activities.by_sport(params[:sport])
    end
  end
end
