# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @streak = ::Analytics::StreakCalculator.new(current_user).call
    @weekly = ::Analytics::WeeklySummary.new(current_user).call
    @volume = ::Analytics::VolumeComparison.new(current_user, period: :month).call
    @fitness = ::TrainingLoad::FitnessCalculator.new(current_user).call.last(30)
    @weekly_volume = weekly_volume_data
    @upcoming_competitions = current_user.competitions.upcoming.limit(3)
    @today_planned = current_user.planned_sessions.for_date(Date.current).ordered
    @today_activities = current_user.activities.for_date(Date.current).chronological
    @current_phase = current_user.training_phases.current.first
    @today_journal = current_user.daily_journals.find_by(date: Date.current)
    @next_session = current_user.planned_sessions
                                .where("date > ?", Date.current)
                                .where(completed: false)
                                .order(:date)
                                .first
    @recent_activities = current_user.activities
                                     .where("performed_at < ?", Time.current)
                                     .chronological
                                     .limit(3)
  end

  private

  def weekly_volume_data
    start = 12.weeks.ago.beginning_of_week.to_date
    weeks = []

    (0..11).each do |i|
      week_start = start + i.weeks
      activities = current_user.activities.for_week(week_start)
      km = activities.sum { |a| a.distance_km || 0 }.round(1)
      hours = (activities.sum { |a| a.duration_seconds || 0 } / 3600.0).round(1)

      # Inclure seulement les semaines avec données ou les 4 dernières
      next if km.zero? && hours.zero? && i < 8

      weeks << {
        week: "S#{week_start.cweek}",
        km: km,
        hours: hours
      }
    end

    weeks
  end
end
