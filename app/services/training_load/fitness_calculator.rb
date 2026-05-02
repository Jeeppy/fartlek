# frozen_string_literal: true

module TrainingLoad
  class FitnessCalculator
    CTL_DAYS = 42
    ATL_DAYS = 7

    def initialize(user, end_date: Date.current)
      @user = user
      @end_date = end_date
      @start_date = end_date - (CTL_DAYS + 30).days
    end

    def call
      daily_trimp = compute_daily_trimp
      ctl = exponential_moving_average(daily_trimp, CTL_DAYS)
      atl = exponential_moving_average(daily_trimp, ATL_DAYS)

      (@start_date..@end_date).map do |date|
        {
          date: date,
          trimp: daily_trimp[date] || 0,
          ctl: ctl[date] || 0,
          atl: atl[date] || 0,
          tsb: (ctl[date] || 0) - (atl[date] || 0)
        }
      end
    end

    private

    def compute_daily_trimp
      activities = @user.activities
                        .where(performed_at: @start_date.beginning_of_day..@end_date.end_of_day)
                        .group_by { |a| a.performed_at.to_date }

      result = {}
      (@start_date..@end_date).each do |date|
        day_activities = activities[date] || []
        result[date] = day_activities.sum do |a|
          TrainingLoad::StressCalculator.new(a, @user).call || 0
        end
      end
      result
    end

    def exponential_moving_average(daily_values, days)
      decay = 2.0 / (days + 1)
      result = {}
      prev = 0.0

      (@start_date..@end_date).each do |date|
        value = daily_values[date] || 0
        prev = (prev * (1 - decay)) + (value * decay)
        result[date] = prev.round(1)
      end
      result
    end
  end
end
