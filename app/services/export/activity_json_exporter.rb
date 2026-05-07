# frozen_string_literal: true

module Export
  class ActivityJsonExporter
    def initialize(activity)
      @activity = activity
    end

    def call
      base_attributes
        .merge(performance_attributes)
        .merge(meta_attributes)
        .merge(planned_session: export_planned_session)
        .compact
    end

    def self.export_collection(activities)
      activities.includes(:activity_tags, :equipment, :activity_laps).map do |activity|
        new(activity).call
      end
    end

    private

    def base_attributes
      {
        date: @activity.performed_at.iso8601,
        sport: @activity.sport,
        title: @activity.title,
        distance_km: @activity.distance_km,
        duration_seconds: @activity.duration_seconds,
        duration_formatted: @activity.duration_formatted,
        elevation_gain_meters: @activity.elevation_gain_meters
      }
    end

    def performance_attributes
      {
        average_pace_formatted: @activity.pace_formatted,
        average_pace_seconds_per_km: @activity.average_pace_seconds_per_km,
        average_heart_rate: @activity.average_heart_rate,
        max_heart_rate: @activity.max_heart_rate,
        average_cadence: @activity.average_cadence,
        average_power: @activity.average_power,
        calories: @activity.calories,
        rpe: @activity.rpe
      }
    end

    def meta_attributes
      {
        tags: @activity.activity_tags.pluck(:name),
        equipment: @activity.equipment&.name,
        notes: @activity.notes,
        laps: export_laps
      }
    end

    def export_planned_session
      return nil unless @activity.planned_session

      ps = @activity.planned_session
      {
        title: ps.title,
        date: ps.date.iso8601,
        sport: ps.sport,
        target_distance_km: ps.target_distance_meters ? (ps.target_distance_meters / 1000.0).round(1) : nil,
        target_duration_formatted: ps.target_duration_formatted,
        target_pace_formatted: ps.target_pace_formatted,
        target_rpe: ps.target_rpe,
        description: ps.description
      }.compact
    end

    def export_laps
      @activity.activity_laps.ordered.map do |lap|
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
  end
end
