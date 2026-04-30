# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    gender { :male }
    date_of_birth { 30.years.ago.to_date }
    time_zone { "Europe/Paris" }
    admin { false }

    trait :female do
      gender { :female }
      first_name { Faker::Name.female_first_name }
    end

    trait :admin do
      admin { true }
    end

    trait :young do
      date_of_birth { 18.years.ago.to_date }
    end

    trait :senior do
      date_of_birth { 55.years.ago.to_date }
    end
  end
end
