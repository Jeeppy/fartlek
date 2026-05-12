# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    load_analytics
    load_planning
    load_recent
  end

  private

  def load_analytics
    @streak = ::Analytics::StreakCalculator.new(current_user).call
    @weekly = ::Analytics::WeeklySummary.new(current_user).call
    @volume = ::Analytics::VolumeComparison.new(current_user, period: :month).call
    @fitness = ::TrainingLoad::FitnessCalculator.new(current_user).call.last(30)
    @weekly_volume = weekly_volume_data
    @current_phase = current_user.training_phases.current.first
  end

  def load_planning
    @upcoming_competitions = current_user.competitions.upcoming.limit(3)
    @today_planned = current_user.planned_sessions.for_date(Date.current).ordered
    @today_journal = current_user.daily_journals.find_by(date: Date.current)
    @next_session = next_planned_session
  end

  def next_planned_session
    current_user.planned_sessions
                .where("date > ?", Date.current)
                .where(completed: false)
                .order(:date)
                .first
  end

  def load_recent
    @today_activities = current_user.activities.for_date(Date.current).chronological
    @recent_activities = current_user.activities
                                     .where(performed_at: ...Time.current)
                                     .chronological
                                     .limit(3)
  end

  def weekly_volume_data
    start = 12.weeks.ago.beginning_of_week.to_date
    (0..11).filter_map { |i| build_week_data(start + i.weeks, i) }
  end

  def build_week_data(week_start, index)
    activities = current_user.activities.for_week(week_start)
    km, hours = sum_week_activities(activities)
    return nil if km.zero? && hours.zero? && index < 8

    { week: "S#{week_start.cweek}", km: km, hours: hours }
  end

  def sum_week_activities(activities)
    km = activities.sum { |a| a.distance_km || 0 }.round(1)
    hours = (activities.sum { |a| a.duration_seconds || 0 } / 3600.0).round(1)
    [km, hours]
  end
end
