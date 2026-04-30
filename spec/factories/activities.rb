# frozen_string_literal: true

FactoryBot.define do
  factory :activity do
    user
    sport { :running }
    title { "Footing matinal" }
    performed_at { 1.hour.ago }
    duration_seconds { 3600 }
    distance_meters { 10_000 }
    elevation_gain_meters { 50 }
    average_heart_rate { 145 }
    max_heart_rate { 165 }
    average_pace_seconds_per_km { 360 }
    calories { 650 }

    trait :cycling do
      sport { :cycling }
      title { "Sortie vélo" }
      distance_meters { 40_000 }
      duration_seconds { 5400 }
      average_pace_seconds_per_km { nil }
      calories { 800 }
    end

    trait :swimming do
      sport { :swimming }
      title { "Natation" }
      distance_meters { 2000 }
      duration_seconds { 2700 }
      average_pace_seconds_per_km { nil }
      elevation_gain_meters { 0 }
    end

    trait :walking do
      sport { :walking }
      title { "Marche" }
      distance_meters { 6000 }
      duration_seconds { 3600 }
      average_pace_seconds_per_km { 600 }
    end

    trait :ppg do
      sport { :ppg }
      title { "Renforcement musculaire" }
      distance_meters { nil }
      duration_seconds { 1800 }
      average_pace_seconds_per_km { nil }
      elevation_gain_meters { nil }
    end

    trait :with_rpe do
      rpe { rand(1..10) }
      feeling { Activity.feelings.keys.sample }
    end

    trait :with_strava do
      strava_id { Faker::Number.unique.number(digits: 10) }
      strava_data { { type: "Run", start_date: performed_at.iso8601 } }
    end

    trait :with_laps do
      transient do
        lap_count { 5 }
      end

      after(:create) do |activity, evaluator|
        create_list(:activity_lap, evaluator.lap_count, activity: activity)
      end
    end
  end
end
