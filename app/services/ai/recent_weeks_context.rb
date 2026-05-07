# frozen_string_literal: true

module Ai
  # Builds recent weeks training context for AI prompt.
  class RecentWeeksContext
    def initialize(user)
      @user = user
    end

    def call
      parts = ["\n## 4 dernières semaines"]
      4.downto(1).each { |i| parts.concat(week_lines(i)) }
      parts.compact.join("\n")
    end

    private

    def week_lines(weeks_ago)
      week_date = Date.current - weeks_ago.weeks
      acts = @user.activities.for_week(week_date).includes(:activity_tags)

      lines = [week_header(weeks_ago, week_date, acts)]
      lines.concat(acts.map { |act| format_activity(act) })
      lines << format_week_journal(week_date)
    end

    def week_header(weeks_ago, week_date, acts)
      km = acts.sum { |act| act.distance_km || 0 }.round(1)
      hours = (acts.sum { |act| act.duration_seconds || 0 } / 3600.0).round(1)
      "\n### S-#{weeks_ago} (#{week_date.beginning_of_week.strftime('%d/%m')})\n" \
        "#{acts.count} séances, #{km} km, #{hours}h"
    end

    def format_activity(act)
      tags = act.activity_tags.pluck(:name).join(", ")
      line = "- #{act.performed_at.strftime('%A')} : #{act.title || act.sport.humanize}"
      line += " — #{act.distance_km}km" if act.distance_km
      line += ", #{act.duration_formatted}" if act.duration_formatted
      line += ", #{act.pace_formatted}" if act.pace_formatted
      line += " [#{tags}]" if tags.present?
      line
    end

    def format_week_journal(week_date)
      journal = @user.weekly_journals.find_by(week_start_date: week_date.beginning_of_week)
      return nil unless journal

      parts = []
      if journal.pleasure
        parts << "Bilan : plaisir #{journal.pleasure}/5, " \
                 "difficulté #{journal.difficulty}/5, fatigue #{journal.fatigue}/5"
      end
      parts << "Note : #{journal.comment}" if journal.comment.present?
      parts.join("\n")
    end
  end
end
