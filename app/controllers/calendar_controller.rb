# frozen_string_literal: true

class CalendarController < ApplicationController
  def show
    @date = if params[:year] && params[:month]
              Date.new(params[:year].to_i, params[:month].to_i, 1)
            else
              Date.current
            end

    @activities = current_user.activities
                              .for_month(@date)
                              .includes(:activity_tags)
                              .group_by { |a| a.performed_at.to_date }

    @planned_sessions = current_user.planned_sessions
                                    .where(date: @date.all_month)
                                    .group_by(&:date)

    @phases = current_user.training_phases.for_month(@date)
    @competitions = current_user.competitions.where(date: @date.all_month)

    @weekly_summaries = build_weekly_summaries
    @prev_month = @date - 1.month
    @next_month = @date + 1.month
  end

  private

  def build_weekly_summaries
    start = @date.beginning_of_month.beginning_of_week
    finish = @date.end_of_month.end_of_week
    summaries = {}

    (start..finish).each_slice(7) do |week|
      week_start = week.first
      week_activities = current_user.activities.for_week(week_start)
      km = week_activities.sum { |a| a.distance_km || 0 }.round(1)
      hours = (week_activities.sum { |a| a.duration_seconds || 0 } / 3600.0).round(1)
      count = week_activities.count

      # Détection patterns
      warnings = detect_warnings(week_start)

      summaries[week_start] = {
        km: km,
        hours: hours,
        count: count,
        warnings: warnings
      }
    end

    summaries
  end

  def detect_warnings(week_start)
    warnings = []
    week_end = week_start + 6.days

    (week_start..week_end).each_cons(3) do |days|
      intensities = days.map do |d|
        day_acts = @activities[d] || []
        tags = day_acts.flat_map { |a| a.activity_tags.pluck(:name) }
        tags.any? { |t| ["Seuil", "VMA", "Fractionné"].include?(t) }
      end

      if intensities.all?
        warnings << "3 jours intensifs consécutifs"
        break
      end
    end

    warnings
  end
end
