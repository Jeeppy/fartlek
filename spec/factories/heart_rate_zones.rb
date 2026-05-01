# frozen_string_literal: true

FactoryBot.define do
  factory :heart_rate_zone do
    user
    sequence(:zone_number) { |n| ((n - 1) % 5) + 1 }
    name { "Zone #{zone_number}" }
    min_bpm { 100 + (zone_number * 15) }
    max_bpm { 115 + (zone_number * 15) }
    color { "#3B82F6" }
  end
end
