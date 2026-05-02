# frozen_string_literal: true

FactoryBot.define do
  factory :strava_credential do
    user
    strava_athlete_id { Faker::Number.number(digits: 8) }
    access_token { SecureRandom.hex(20) }
    refresh_token { SecureRandom.hex(20) }
    expires_at { 6.hours.from_now }

    trait :expired do
      expires_at { 1.hour.ago }
    end
  end
end
