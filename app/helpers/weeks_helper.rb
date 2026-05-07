# frozen_string_literal: true

module WeeksHelper
  def summary_by_sport(activities)
    activities.group_by(&:sport).transform_values do |acts|
      sport_summary(acts)
    end
  end

  def week_totals(activities)
    {
      count: activities.size,
      distance_km: activities.sum { |act| act.distance_km || 0 }.round(2),
      duration_seconds: activities.sum { |act| act.duration_seconds || 0 },
      elevation: activities.sum { |act| act.elevation_gain_meters || 0 }
    }
  end

  private

  def sport_summary(acts)
    {
      count: acts.size,
      distance_km: acts.sum { |act| act.distance_km || 0 }.round(2),
      duration_seconds: acts.sum { |act| act.duration_seconds || 0 },
      elevation: acts.sum { |act| act.elevation_gain_meters || 0 }
    }
  end
end
