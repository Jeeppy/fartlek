# frozen_string_literal: true

# Generates textual insights about a training week.
module Training
  class WeekInsights
    def initialize(analyzer)
      @analyzer = analyzer
      @activities = analyzer.activities
      @stats = analyzer.stats
    end

    def call
      parts = []
      parts << volume_summary
      parts << compliance_insight
      parts << projection_insight
      parts << missed_insight
      parts.concat(warning_insights)
      parts << rpe_trend_insight
      parts.compact
    end

    private

    def volume_summary
      km = @activities.sum { |activity| activity.distance_km || 0 }.round(1)
      hours = (@activities.sum { |activity| activity.duration_seconds || 0 } / 3600.0).round(1)
      { text: "#{@activities.count} séances — #{km}km — #{hours}h", type: :info }
    end

    def compliance_insight
      compliance = @stats[:compliance]
      return nil unless compliance

      color = if compliance >= 80
                :good
              else
                (compliance >= 50 ? :info : :warning)
              end
      completed = @stats[:completed_count]
      total = @stats[:planned_count]
      { text: "Plan respecté à #{compliance}% (#{completed}/#{total})", type: color }
    end

    def projection_insight
      return nil unless @analyzer.current_week?

      remaining = @stats[:remaining_count]
      return nil unless remaining.positive?

      titles = @stats[:remaining_sessions].map(&:title).first(2).join(", ")
      suffix = remaining > 2 ? " + #{remaining - 2} autre(s)" : ""
      { text: "#{remaining} séance(s) restante(s) : #{titles}#{suffix}", type: :info }
    end

    def missed_insight
      daily = @analyzer.send(:build_daily_load)
      missed_count = daily.count { |day| day[:status] == :missed }
      return nil unless missed_count.positive?

      { text: "#{missed_count} séance(s) manquée(s)", type: :warning }
    end

    def warning_insights
      scorer = WeekScorer.new(@analyzer)
      scorer.call[:warnings].map { |warning| { text: warning, type: :warning } }
    end

    def rpe_trend_insight
      rpes = @activities.sort_by(&:performed_at).filter_map(&:rpe)
      return nil if rpes.size < 3

      trend = (rpes.last(3).sum.to_f / 3) - (rpes.first(3).sum.to_f / 3)
      return nil unless trend > 1.5

      { text: "RPE en hausse en fin de semaine, signe de fatigue", type: :warning }
    end
  end
end
