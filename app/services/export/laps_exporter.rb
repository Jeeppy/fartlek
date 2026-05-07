# frozen_string_literal: true

module Export
  module LapsExporter
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
  end
end
