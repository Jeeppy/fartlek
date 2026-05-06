# frozen_string_literal: true

module Export
  class WeekJsonExporter
    def initialize(user, date)
      @user = user
      @start = date.beginning_of_week
      @end_of_week = date.end_of_week
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
      @journal ||= @user.weekly_journals.find_by(week_start_date: @start)
    end

    def export_days
      (@start..@end_of_week).map do |day|
        day_planned = planned_sessions.select { |p| p.date == day }
        day_activities = activities.select { |a| a.performed_at.to_date == day }

        {
          date: day.iso8601,
          day_name: I18n.l(day, format: "%A").capitalize,
          planned: day_planned.map { |p| export_planned(p) },
          activities: day_activities.map { |a| export_activity(a) }
        }
      end
    end

    def export_planned(planned)
      data = {
        id: planned.id,
        title: planned.title,
        sport: planned.sport,
        completed: planned.completed?,
        target_distance_km: planned.target_distance_meters ? (planned.target_distance_meters / 1000.0).round(1) : nil,
        target_duration_formatted: planned.target_duration_formatted,
        target_pace_formatted: planned.target_pace_formatted,
        target_rpe: planned.target_rpe,
        description: planned.description
      }.compact

      data[:linked_activity_id] = planned.activity.id if planned.activity

      data
    end

    def export_activity(activity)
      data = {
        id: activity.id,
        title: activity.title,
        sport: activity.sport,
        date: activity.performed_at.iso8601,
        distance_km: activity.distance_km,
        duration_formatted: activity.duration_formatted,
        pace_formatted: activity.pace_formatted,
        average_heart_rate: activity.average_heart_rate,
        max_heart_rate: activity.max_heart_rate,
        average_cadence: activity.average_cadence,
        average_power: activity.average_power,
        calories: activity.calories,
        rpe: activity.rpe,
        tags: activity.activity_tags.pluck(:name),
        equipment: activity.equipment&.name,
        laps: export_laps(activity)
      }.compact

      data[:linked_planned_id] = activity.planned_session.id if activity.planned_session

      data
    end

    def export_laps(activity)
      activity.activity_laps.ordered.map do |lap|
        {
          lap_number: lap.lap_number,
          distance_km: lap.distance_meters ? (lap.distance_meters / 1000.0).round(2) : nil,
          duration_seconds: lap.duration_seconds,
          pace_formatted: lap.pace_formatted,
          heart_rate: lap.average_heart_rate,
          cadence: lap.average_cadence,
          power: lap.average_power,
          elevation_gain_meters: lap.elevation_gain_meters
        }.compact
      end
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
