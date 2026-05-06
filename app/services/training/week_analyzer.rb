# frozen_string_literal: true

module Training
  class WeekAnalyzer
    QUALITY_TAGS = ["Seuil", "VMA", "Fractionné", "Allure spécifique"].freeze
    EASY_TAGS = ["Endurance fondamentale", "Récupération", "Sortie longue"].freeze

    def initialize(user, date)
      @user = user
      @date = date
      @start = date.beginning_of_week
      @end_of_week = date.end_of_week
    end

    def call
      {
        score: week_score,
        stats: week_stats,
        daily_load: daily_load,
        analysis: analysis_text
      }
    end

    private

    def activities
      @activities ||= @user.activities.for_week(@date).includes(:activity_tags, :planned_session)
    end

    def planned
      @planned ||= @user.planned_sessions.for_week(@date).includes(:activity)
    end

    def journal
      @journal ||= @user.weekly_journals.find_by(week_start_date: @start)
    end

    def current_week?
      @start <= Date.current && @end_of_week >= Date.current
    end

    def last_relevant_day
      current_week? ? Date.current : @end_of_week
    end

    def relevant_planned
      @relevant_planned ||= planned.select { |p| p.date <= last_relevant_day }
    end

    def rest_days_count
      days_elapsed = (@start..last_relevant_day).count
      active_days = activities.select { |a| a.performed_at.to_date <= last_relevant_day }
                              .map { |a| a.performed_at.to_date }.uniq.count
      days_elapsed - active_days
    end

    def compliance_percent
      return nil if relevant_planned.empty?

      ((relevant_planned.select(&:completed?).count.to_f / relevant_planned.count) * 100).round(0)
    end

    def planned_quality_count
      planned.joins(:activity_tags).where(activity_tags: { name: QUALITY_TAGS }).distinct.count
    rescue StandardError
      0
    end

    def week_stats
      quality_done = activities.joins(:activity_tags).where(activity_tags: { name: QUALITY_TAGS }).distinct.count
      quality_planned_total = planned.select do |p|
        p.title.match?(/seuil|vma|frac|spécifique/i)
      end.count

      remaining = planned.select { |p| p.date > Date.current && !p.completed? }

      {
        avg_rpe: activities.where.not(rpe: nil).average(:rpe)&.round(1),
        quality_done: quality_done,
        quality_planned: [quality_planned_total, quality_done].max,
        easy_count: activities.joins(:activity_tags).where(activity_tags: { name: EASY_TAGS }).distinct.count,
        rest_days: rest_days_count,
        planned_count: relevant_planned.count,
        completed_count: relevant_planned.select(&:completed?).count,
        compliance: compliance_percent,
        remaining_count: remaining.count,
        remaining_sessions: remaining
      }
    end

    def daily_load
      (@start..@end_of_week).map do |day|
        day_activities = activities.select { |a| a.performed_at.to_date == day }
        day_planned = planned.select { |p| p.date == day }

        rpe_avg = day_activities.filter_map(&:rpe).then { |r| r.any? ? (r.sum.to_f / r.size).round(1) : nil }

        {
          date: day,
          intensity: day_intensity(day_activities, rpe_avg),
          status: day_status(day, day_activities, day_planned),
          rpe: rpe_avg
        }
      end
    end

    def day_intensity(day_activities, rpe)
      return :rest if day_activities.empty?
      return :hard if rpe && rpe >= 7
      return :moderate if rpe && rpe >= 5

      :easy
    end

    def day_status(day, day_activities, day_planned)
      past = day < Date.current

      if day_planned.empty? && day_activities.empty?
        :rest
      elsif day_planned.empty? && day_activities.any?
        :unplanned
      elsif day_planned.any? && day_activities.empty? && past
        :missed
      elsif day_planned.any? && day_activities.empty?
        :upcoming
      elsif day_planned.all?(&:completed?)
        :completed
      else
        :partial
      end
    end

    def week_score
      ws = week_stats
      score = 0
      warnings = []

      if current_week?
        score += 1
      elsif ws[:rest_days] >= 1
        score += 1
      else
        warnings << "Aucun jour de repos"
      end

      if ws[:quality_done] <= 2
        score += 1
      else
        warnings << "#{ws[:quality_done]} séances intensité (max 2 recommandé)"
      end

      if ws[:compliance].nil? || ws[:compliance] >= 80
        score += 1
      elsif ws[:compliance] < 50
        warnings << "Faible adhérence au plan (#{ws[:compliance]}%)"
      end

      if ws[:avg_rpe].nil? || ws[:avg_rpe] <= 6
        score += 1
      elsif ws[:avg_rpe] > 7
        warnings << "RPE moyen élevé (#{ws[:avg_rpe]})"
      end

      level = case score
              when 4 then :balanced
              when 2..3 then :loaded
              else :risky
              end

      { level: level, score: score, warnings: warnings }
    end

    def analysis_text
      parts = []
      ws = week_stats

      km = activities.sum { |a| a.distance_km || 0 }.round(1)
      hours = (activities.sum { |a| a.duration_seconds || 0 } / 3600.0).round(1)
      parts << { text: "#{activities.count} séances — #{km}km — #{hours}h", type: :info }

      if ws[:compliance]
        color = if ws[:compliance] >= 80
                  :good
                else
                  ws[:compliance] >= 50 ? :info : :warning
                end
        parts << { text: "Plan respecté à #{ws[:compliance]}% (#{ws[:completed_count]}/#{ws[:planned_count]})",
                   type: color }
      end

      # Projection
      if current_week? && ws[:remaining_count] > 0
        remaining_titles = ws[:remaining_sessions].map(&:title).first(2).join(", ")
        suffix = ws[:remaining_count] > 2 ? " + #{ws[:remaining_count] - 2} autre(s)" : ""
        parts << { text: "#{ws[:remaining_count]} séance(s) restante(s) : #{remaining_titles}#{suffix}", type: :info }
      end

      # Missed
      missed = daily_load.select { |d| d[:status] == :missed }
      parts << { text: "#{missed.count} séance(s) manquée(s)", type: :warning } if missed.any?

      week_score[:warnings].each { |w| parts << { text: w, type: :warning } }

      rpes = activities.sort_by(&:performed_at).filter_map(&:rpe)
      if rpes.size >= 3
        trend = (rpes.last(3).sum.to_f / 3) - (rpes.first(3).sum.to_f / 3)
        parts << { text: "RPE en hausse en fin de semaine, signe de fatigue", type: :warning } if trend > 1.5
      end

      parts
    end
  end
end
