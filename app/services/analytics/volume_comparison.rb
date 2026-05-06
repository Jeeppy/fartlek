# frozen_string_literal: true

module Analytics
  class VolumeComparison
    def initialize(user, period: :month, date: Date.current)
      @user = user
      @period = period
      @date = date
    end

    def call
      {
        current: period_data(@date),
        previous: period_data(previous_date),
        delta: compute_delta
      }
    end

    private

    def period_data(date)
      activities = activities_for(date)
      {
        distance_km: activities.sum { |a| a.distance_km || 0 }.round(2),
        duration_seconds: activities.sum { |a| a.duration_seconds || 0 },
        count: activities.count,
        elevation: activities.sum { |a| a.elevation_gain_meters || 0 }
      }
    end

    def activities_for(date)
      case @period
      when :week  then @user.activities.for_week(date)
      when :month then @user.activities.for_month(date)
      when :year  then @user.activities.for_year(date)
      end
    end

    def previous_date
      case @period
      when :week  then @date - 1.week
      when :month then @date - 1.month
      when :year  then @date - 1.year
      end
    end

    def compute_delta
      current = period_data(@date)
      previous = period_data(previous_date)
      {
        distance_km: delta_percent(current[:distance_km], previous[:distance_km]),
        duration: delta_percent(current[:duration_seconds], previous[:duration_seconds]),
        count: current[:count] - previous[:count]
      }
    end

    def delta_percent(current, previous)
      return 0 if previous.zero?

      (((current - previous).to_f / previous) * 100).round(1)
    end
  end
end
