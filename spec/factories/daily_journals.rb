# frozen_string_literal: true

FactoryBot.define do
  factory :daily_journal do
    user
    date { Date.current }
    mood { 4 }
    sleep_quality { 4 }
    sleep_hours { 7.5 }
    fatigue { 2 }
    soreness { 2 }
    comment { "Bonne journée" }
  end
end
