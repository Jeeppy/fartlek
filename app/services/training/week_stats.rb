# frozen_string_literal: true

# Computes weekly statistics from activities and planned sessions.
module Training
  class WeekStats
    def initialize(analyzer)
      @analyzer = analyzer
      @activities = analyzer.activities
      @planned = analyzer.planned
    end

    def call
      {
        avg_rpe: average_rpe,
        quality_done: quality_done_count,
        quality_planned: [quality_planned_count, quality_done_count].max,
        easy_count: easy_count,
        rest_days: rest_days_count,
        planned_count: relevant_planned.count,
        completed_count: relevant_planned.count(&:completed?),
        compliance: compliance_percent,
        remaining_count: remaining_sessions.count,
        remaining_sessions: remaining_sessions
      }
    end

    private

    def average_rpe
      @activities.where.not(rpe: nil).average(:rpe)&.round(1)
    end

    def quality_done_count
      @activities.joins(:activity_tags)
                 .where(activity_tags: { name: WeekAnalyzer::QUALITY_TAGS })
                 .distinct.count
    end

    def quality_planned_count
      @planned.count { |session| session.title.match?(/seuil|vma|frac|spécifique/i) }
    end

    def easy_count
      @activities.joins(:activity_tags)
                 .where(activity_tags: { name: WeekAnalyzer::EASY_TAGS })
                 .distinct.count
    end

    def relevant_planned
      @relevant_planned ||= @planned.select { |session| session.date <= @analyzer.last_relevant_day }
    end

    def remaining_sessions
      @remaining_sessions ||= @planned.select { |session| session.date > Date.current && !session.completed? }
    end

    def rest_days_count
      days_elapsed = (@analyzer.date_range.first..@analyzer.last_relevant_day).count
      active_days = @activities
                    .select { |act| act.performed_at.to_date <= @analyzer.last_relevant_day }
                    .map { |act| act.performed_at.to_date }
                    .uniq.count
      days_elapsed - active_days
    end

    def compliance_percent
      return nil if relevant_planned.empty?

      ((relevant_planned.count(&:completed?).to_f / relevant_planned.count) * 100).round(0)
    end
  end
end
