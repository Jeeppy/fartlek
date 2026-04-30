# frozen_string_literal: true

FactoryBot.define do
  factory :activity_lap do
    activity
    sequence(:lap_number)
    distance_meters { 1000 }
    duration_seconds { 360 }
    average_heart_rate { 150 }
    average_pace_seconds_per_km { 360 }
    elevation_gain_meters { 10 }
  end
end
