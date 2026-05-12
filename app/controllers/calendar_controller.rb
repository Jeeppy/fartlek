# frozen_string_literal: true

class CalendarController < ApplicationController
  def show
    set_dates
    load_calendar_data
    @weekly_summaries = build_weekly_summaries
  end

  private

  def set_dates
    @date = parse_date
    @prev_month = @date - 1.month
    @next_month = @date + 1.month
  end

  def parse_date
    return Date.current unless params[:year] && params[:month]

    Date.new(params[:year].to_i, params[:month].to_i, 1)
  end

  def load_calendar_data
    @activities = current_user.activities
                              .for_month(@date)
                              .includes(:activity_tags)
                              .group_by { |a| a.performed_at.to_date }
    @planned_sessions = current_user.planned_sessions
                                    .where(date: @date.all_month)
                                    .group_by(&:date)
    @phases = current_user.training_phases.for_month(@date)
    @competitions = current_user.competitions.where(date: @date.all_month)
  end

  def build_weekly_summaries
    start = @date.beginning_of_month.beginning_of_week
    finish = @date.end_of_month.end_of_week
    (start..finish).each_slice(7).to_h do |week|
      [week.first, week_summary(week.first)]
    end
  end

  def week_summary(week_start)
    acts = current_user.activities.for_week(week_start)
    {
      km: acts.sum { |a| a.distance_km || 0 }.round(1),
      hours: (acts.sum { |a| a.duration_seconds || 0 } / 3600.0).round(1),
      count: acts.count,
      warnings: detect_warnings(week_start)
    }
  end

  def detect_warnings(week_start)
    warnings = []
    days = (week_start..(week_start + 6.days)).to_a
    days.each_cons(3) do |trio|
      if trio.all? { |day| day_intensive?(day) }
        warnings << "3 jours intensifs consécutifs"
        break
      end
    end
    warnings
  end

  def day_intensive?(day)
    tags = (@activities[day] || []).flat_map { |act| act.activity_tags.pluck(:name) }
    tags.any? { |tag| ["Seuil", "VMA", "Fractionné"].include?(tag) }
  end
end
