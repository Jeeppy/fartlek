# frozen_string_literal: true

# Analyses weekly training data and provides score, stats, and insights.
module Training
  class WeekAnalyzer
    QUALITY_TAGS = ["Seuil", "VMA", "Fractionné", "Allure spécifique"].freeze
    EASY_TAGS = ["Endurance fondamentale", "Récupération", "Sortie longue"].freeze

    attr_reader :activities, :planned, :stats

    def initialize(user, date)
      @user = user
      @date = date
      @start = date.beginning_of_week
      @end_of_week = date.end_of_week
      @activities = user.activities.for_week(date).includes(:activity_tags, :planned_session)
      @planned = user.planned_sessions.for_week(date).includes(:activity)
    end

    def call
      @stats = WeekStats.new(self).call
      {
        score: WeekScorer.new(self).call,
        stats: @stats,
        daily_load: build_daily_load,
        analysis: WeekInsights.new(self).call
      }
    end

    def current_week?
      Date.current.between?(@start, @end_of_week)
    end

    def last_relevant_day
      current_week? ? Date.current : @end_of_week
    end

    def date_range
      @start..@end_of_week
    end

    private

    def build_daily_load
      date_range.map do |day|
        day_acts = activities.select { |act| act.performed_at.to_date == day }
        day_plan = planned.select { |pl| pl.date == day }
        rpe_avg = compute_rpe(day_acts)

        {
          date: day,
          intensity: classify_intensity(day_acts, rpe_avg),
          status: classify_status(day, day_acts, day_plan),
          rpe: rpe_avg
        }
      end
    end

    def compute_rpe(day_acts)
      rpes = day_acts.filter_map(&:rpe)
      return nil if rpes.empty?

      (rpes.sum.to_f / rpes.size).round(1)
    end

    def classify_intensity(day_acts, rpe)
      return :rest if day_acts.empty?
      return :hard if rpe && rpe >= 7
      return :moderate if rpe && rpe >= 5

      :easy
    end

    def classify_status(day, day_acts, day_plan)
      return :rest unless day_acts.any? || day_plan.any?
      return :unplanned if day_plan.empty?
      return :completed if day_plan.all?(&:completed?)

      classify_planned_status(day, day_acts)
    end

    def classify_planned_status(day, day_acts)
      past = day < Date.current
      return :missed if day_acts.empty? && past
      return :upcoming if day_acts.empty?

      :partial
    end
  end
end
