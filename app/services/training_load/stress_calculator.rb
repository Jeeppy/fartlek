# frozen_string_literal: true

module TrainingLoad
  class StressCalculator
    # TRIMP simplifié basé sur la FC
    # Nécessite : duration_seconds, average_heart_rate, resting_hr, max_hr
    def initialize(activity, user)
      @activity = activity
      @user = user
    end

    def call
      return nil unless valid?

      duration_minutes = @activity.duration_seconds / 60.0
      hr_fraction = (@activity.average_heart_rate - resting_hr).to_f / (max_hr - resting_hr)
      hr_fraction = hr_fraction.clamp(0.0, 1.0)

      gender_factor = @user.female? ? 1.67 : 1.92

      (duration_minutes * hr_fraction * 0.64 * Math.exp(gender_factor * hr_fraction)).round(1)
    end

    private

    def valid?
      @activity.duration_seconds.present? &&
        @activity.average_heart_rate.present? &&
        max_hr > resting_hr
    end

    def resting_hr
      @resting_hr ||= latest_metric(:resting_hr)&.value&.to_i || 60
    end

    def max_hr
      @max_hr ||= @user.estimated_max_hr
    end

    def latest_metric(type)
      @user.user_metrics.by_type(type).recent_first.first
    end
  end
end
