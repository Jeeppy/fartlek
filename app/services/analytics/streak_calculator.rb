# frozen_string_literal: true

module Analytics
  class StreakCalculator
    def initialize(user)
      @user = user
    end

    def call
      dates = @user.activities
                   .where("performed_at >= ?", 1.year.ago)
                   .order(performed_at: :desc)
                   .pluck(:performed_at)
                   .map { |d| d.to_date }
                   .uniq

      return 0 if dates.empty?

      streak = 0
      current = Date.current

      # Si pas d'activité aujourd'hui, commencer à hier
      current -= 1.day unless dates.include?(current)

      dates.each do |date|
        break unless date == current

        streak += 1
        current -= 1.day
      end

      streak
    end
  end
end
