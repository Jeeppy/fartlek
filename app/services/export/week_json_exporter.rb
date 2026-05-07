# frozen_string_literal: true

module Export
  class WeekJsonExporter
    include LapsExporter

    def initialize(user, date)
      @user = user
      @start = date.beginning_of_week
      @end_of_week = date.end_of_month
    end

    def call
      {
        week: "#{@start.iso8601}/#{@end_of_week.iso8601}",
        days: export_days,
        journal: export_journal
      }
    end

    private

    def planned_sessions
      @planned_sessions ||= @user.planned_sessions
                                 .for_week(@start)
                                 .includes(:activity)
                                 .ordered
    end

    def activities
      @activities ||= @user.activities
                           .for_week(@start)
                           .includes(:activity_tags, :equipment, :activity_laps, :planned_session)
                           .chronological
    end

    def journal
      return @journal if defined?(@journal)

      @journal = @user.weekly_journals.find_by(week_start_date: @start)
    end

    def export_days
      (@start..@end_of_week).map do |day|
        {
          date: day.iso8601,
          day_name: I18n.l(day, format: "%A").capitalize,
          planned: planned_sessions.select { |ps| ps.date == day }.map { |ps| export_planned(ps) },
          activities: activities.select { |act| act.performed_at.to_date == day }.map { |act| export_activity(act) }
        }
      end
    end

    def export_planned(planned)
      {
        id: planned.id,
        title: planned.title,
        sport: planned.sport,
        completed: planned.completed?,
        target_distance_km: planned.target_distance_meters ? (planned.target_distance_meters / 1000.0).round(1) : nil,
        target_duration_formatted: planned.target_duration_formatted,
        target_pace_formatted: planned.target_pace_formatted,
        target_rpe: planned.target_rpe,
        description: planned.description,
        linked_activity_id: planned.activity&.id
      }.compact
    end

    def export_activity(activity)
      activity_base(activity)
        .merge(activity_performance(activity))
        .merge(activity_relations(activity))
        .compact
    end

    def activity_base(activity)
      {
        id: activity.id,
        title: activity.title,
        sport: activity.sport,
        date: activity.performed_at.iso8601,
        distance_km: activity.distance_km,
        duration_formatted: activity.duration_formatted,
        pace_formatted: activity.pace_formatted
      }
    end

    def activity_performance(activity)
      {
        average_heart_rate: activity.average_heart_rate,
        max_heart_rate: activity.max_heart_rate,
        average_cadence: activity.average_cadence,
        average_power: activity.average_power,
        calories: activity.calories,
        rpe: activity.rpe
      }
    end

    def activity_relations(activity)
      {
        tags: activity.activity_tags.pluck(:name),
        equipment: activity.equipment&.name,
        linked_planned_id: activity.planned_session&.id,
        laps: export_laps(activity)
      }
    end

    def export_journal
      return nil unless journal

      {
        pleasure: journal.pleasure,
        difficulty: journal.difficulty,
        fatigue: journal.fatigue,
        comment: journal.comment
      }.compact
    end
  end
end
