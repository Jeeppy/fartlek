# frozen_string_literal: true

module Analytics
  class PaceProgression
    DISTANCES = {
      "5km" => 4_500..5_500,
      "10km" => 9_000..11_000,
      "Semi" => 20_000..22_000,
      "Marathon" => 41_000..43_000
    }.freeze

    def initialize(user)
      @user = user
    end

    def call
      DISTANCES.transform_values do |range|
        @user.activities
             .running
             .where(distance_meters: range)
             .where.not(average_pace_seconds_per_km: nil)
             .order(performed_at: :asc)
             .pluck(:performed_at, :average_pace_seconds_per_km)
             .map { |date, pace| { date: date.to_date, pace: pace } }
      end
    end
  end
end
