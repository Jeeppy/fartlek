# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    @streak = ::Analytics::StreakCalculator.new(current_user).call
    @weekly = ::Analytics::WeeklySummary.new(current_user).call
    @volume = ::Analytics::VolumeComparison.new(current_user, period: :month).call
    @fitness = ::TrainingLoad::FitnessCalculator.new(current_user).call.last(30)
  end
end
