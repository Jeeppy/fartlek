# frozen_string_literal: true

FactoryBot.define do
  factory :pace_zone do
    user
    sequence(:zone_number) { |n| ((n - 1) % 7) + 1 }
    name { "Zone #{zone_number}" }
    min_pace_seconds_per_km { 450 - (zone_number * 30) }
    max_pace_seconds_per_km { 480 - (zone_number * 30) }
    color { "#22C55E" }
  end
end
