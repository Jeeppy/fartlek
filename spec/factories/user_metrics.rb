# frozen_string_literal: true

FactoryBot.define do
  factory :user_metric do
    user
    recorded_on { Date.current }
    metric_type { :weight }
    value { 75.5 }
    unit { "kg" }

    trait :resting_hr do
      metric_type { :resting_hr }
      value { 52 }
      unit { "bpm" }
    end

    trait :vma do
      metric_type { :vma_test }
      value { 18.5 }
      unit { "km/h" }
    end
  end
end
