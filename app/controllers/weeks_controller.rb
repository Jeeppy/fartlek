# frozen_string_literal: true

class WeeksController < ApplicationController
  def show
    @date = Date.parse(params[:date])
    @start_of_week = @date.beginning_of_week
    @end_of_week = @date.end_of_week

    @activities = current_user.activities.for_week(@date).chronological
    @prev_week = @start_of_week - 1.week
    @next_week = @start_of_week + 1.week
  end

  private

  def summary_by_sport
    @summary_by_sport ||= @activities.group_by(&:sport).transform_values do |acts|
      {
        count: acts.size,
        distance_km: acts.sum { |a| a.distance_km || 0 }.round(2),
        duration_seconds: acts.sum { |a| a.duration_seconds || 0 },
        elevation: acts.sum { |a| a.elevation_gain_meters || 0 }
      }
    end
  end
  helper_method :summary_by_sport

  def week_totals
    @week_totals ||= {
      count: @activities.size,
      distance_km: @activities.sum { |a| a.distance_km || 0 }.round(2),
      duration_seconds: @activities.sum { |a| a.duration_seconds || 0 },
      elevation: @activities.sum { |a| a.elevation_gain_meters || 0 }
    }
  end
  helper_method :week_totals

  def format_duration(seconds)
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    format("%<h>dh%<m>02d", h: hours, m: minutes)
  end
  helper_method :format_duration
end
