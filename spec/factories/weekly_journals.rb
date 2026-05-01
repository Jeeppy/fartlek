# frozen_string_literal: true

FactoryBot.define do
  factory :weekly_journal do
    user
    week_start_date { Date.current.beginning_of_week }
    pleasure { 4 }
    difficulty { 3 }
    fatigue { 5 }
    comment { "Bonne semaine" }
  end
end
