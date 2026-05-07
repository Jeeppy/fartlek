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
      acts = @user.activities.for_week(date)
      {
        count: acts.count,
        distance_km: sum_distance(acts),
        duration_seconds: sum_duration(acts),
        elevation: sum_elevation(acts),
        by_sport: by_sport(acts)
      }
    end

    def sum_distance(acts)
      acts.sum { |a| a.distance_km || 0 }.round(2)
    end

    def sum_duration(acts)
      acts.sum { |a| a.duration_seconds || 0 }
    end

    def sum_elevation(acts)
      acts.sum { |a| a.elevation_gain_meters || 0 }
    end

    def by_sport(acts)
      acts.group_by(&:sport).transform_values do |sport_acts|
        {
          count: sport_acts.size,
          distance_km: sport_acts.sum { |a| a.distance_km || 0 }.round(2),
          duration_seconds: sport_acts.sum { |a| a.duration_seconds || 0 }
        }
      end
    end
  end
end
