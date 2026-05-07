# frozen_string_literal: true

module Strava
  class ActivityMapper
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
      base_attributes.merge(performance_attributes).merge(
        strava_data: @data,
        laps: map_laps
      )
    end

    private

    def base_attributes
      {
        strava_id: @data["id"],
        title: @data["name"],
        sport: self.class.map_sport(@data["type"]),
        performed_at: Time.zone.parse(@data["start_date"]),
        duration_seconds: @data["elapsed_time"],
        distance_meters: positive_int(@data["distance"]),
        elevation_gain_meters: positive_int(@data["total_elevation_gain"])
      }
    end

    def performance_attributes
      {
        average_heart_rate: positive_int(@data["average_heartrate"]),
        max_heart_rate: positive_int(@data["max_heartrate"]),
        calories: positive_int(@data["calories"]),
        average_pace_seconds_per_km: speed_to_pace(@data["average_speed"]),
        average_cadence: cadence(@data["average_cadence"]),
        average_power: positive_int(@data["average_watts"])
      }
    end

    def positive_int(value)
      value&.positive? ? value.to_i : nil
    end

    def speed_to_pace(speed)
      return nil if speed.nil? || speed.zero?

      (1000.0 / speed).round
    end

    def cadence(value)
      return nil if value.nil? || value.zero?

      (value.to_i * 2)
    end

    def map_laps
      return [] unless @data["laps"]

      @data["laps"].map { |lap| map_lap(lap) }
    end

    def map_lap(lap)
      {
        lap_number: lap["lap_index"],
        distance_meters: positive_int(lap["distance"]),
        duration_seconds: lap["elapsed_time"],
        elevation_gain_meters: positive_int(lap["total_elevation_gain"]),
        average_heart_rate: positive_int(lap["average_heartrate"]),
        average_pace_seconds_per_km: speed_to_pace(lap["average_speed"]),
        average_cadence: cadence(lap["average_cadence"]),
        average_power: positive_int(lap["average_watts"])
      }.compact
    end
  end
end
