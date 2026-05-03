# frozen_string_literal: true

module Strava
  class ActivityMapper
    attr_reader :data

    SPORTS = {
      Run: "running",
      Ride: "cycling",
      Swim: "swimming",
      Walk: "walking",
      Workout: "ppg",
      WeightTraining: "ppg"
    }.freeze

    def self.map_sport(sport)
      SPORTS.with_indifferent_access.fetch(sport, nil)
    end

    def initialize(user, data)
      @user = user
      @data = data
    end

    def call
      {
        strava_data: data,
        strava_id: data["id"],
        title: data["name"],
        sport: ActivityMapper.map_sport(data["type"]),
        duration_seconds: data["elapsed_time"],
        distance_meters: data["distance"]&.positive? ? data["distance"].to_i : nil,
        elevation_gain_meters: data["total_elevation_gain"]&.positive? ? data["total_elevation_gain"].to_i : nil,
        average_heart_rate: data["average_heartrate"]&.positive? ? data["average_heartrate"].to_i : nil,
        max_heart_rate: data["max_heartrate"]&.positive? ? data["max_heartrate"].to_i : nil,
        average_cadence: data["average_cadence"]&.to_i&.positive? ? data["average_cadence"].to_i : nil,
        average_power: data["average_watts"]&.to_i&.positive? ? data["average_watts"].to_i : nil,
        calories: data["calories"]&.positive? ? data["calories"].to_i : nil,
        average_pace_seconds_per_km: speed_to_pace(data["average_speed"]),
        performed_at: Time.zone.parse(data["start_date"]),
        laps: map_laps
      }
    end

    private

    def speed_to_pace(speed)
      return nil if speed.nil? || speed.zero?

      (1000.0 / speed).round
    end

    def map_laps
      return if data["laps"].nil?

      data["laps"].map do |lap|
        {
          average_heart_rate: lap["average_heartrate"],
          average_pace_seconds_per_km: speed_to_pace(lap["average_speed"]),
          average_cadence: lap["average_cadence"]&.to_i&.positive? ? lap["average_cadence"].to_i : nil,
          average_power: lap["average_watts"]&.to_i&.positive? ? lap["average_watts"].to_i : nil,
          distance_meters: lap["distance"],
          duration_seconds: lap["elapsed_time"],
          elevation_gain_meters: lap["total_elevation_gain"],
          lap_number: lap["lap_index"]
        }
      end
    end
  end
end
