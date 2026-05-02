# frozen_string_literal: true

module Analytics
  class WeeklySummary
    def initialize(user, date: Date.current)
      @user = user
      @date = date
    end

    def call
      {
        current: week_data(@date),
        previous: week_data(@date - 1.week)
      }
    end

    private

    def week_data(date)
      activities = @user.activities.for_week(date)
      {
        count: activities.count,
        distance_km: activities.sum { |a| a.distance_km || 0 }.round(2),
        duration_seconds: activities.sum { |a| a.duration_seconds || 0 },
        elevation: activities.sum { |a| a.elevation_gain_meters || 0 },
        by_sport: activities.group_by(&:sport).transform_values do |acts|
          {
            count: acts.size,
            distance_km: acts.sum { |a| a.distance_km || 0 }.round(2),
            duration_seconds: acts.sum { |a| a.duration_seconds || 0 }
          }
        end
      }
    end
  end
end
