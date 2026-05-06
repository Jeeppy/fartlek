# frozen_string_literal: true

module Export
  class WeeksController < ApplicationController
    def show
      date = Date.parse(params[:date])
      data = ::Export::WeekJsonExporter.new(current_user, date).call

      send_data data.to_json,
                filename: "fartlek_week_#{date.beginning_of_week}.json",
                type: :json
    end
  end
end
