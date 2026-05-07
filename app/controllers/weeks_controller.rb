# frozen_string_literal: true

class WeeksController < ApplicationController
  def show
    set_dates
    load_data
  end

  private

  def set_dates
    @date = Date.parse(params[:date])
    @start_of_week = @date.beginning_of_week
    @end_of_week = @date.end_of_week
    @prev_week = @start_of_week - 1.week
    @next_week = @start_of_week + 1.week
  end

  def load_data
    @activities = current_user.activities
                              .for_week(@date)
                              .includes(:activity_tags, :equipment, :planned_session)
                              .chronological
    @planned_sessions = current_user.planned_sessions.for_week(@date).ordered
    @weekly_journal = current_user.weekly_journals.find_by(week_start_date: @start_of_week)
    @week_analysis = ::Training::WeekAnalyzer.new(current_user, @date).call
  end
end
