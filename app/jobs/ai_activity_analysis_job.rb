# frozen_string_literal: true

class AiActivityAnalysisJob < ApplicationJob
  queue_as :low

  def perform(activity_id)
    activity = Activity.find(activity_id)
    return if activity.analyzed?
    return unless activity.running?
    return if ENV["ANTHROPIC_API_KEY"].blank?

    ::Ai::ActivityAnalyzer.new(activity, activity.user).call
  rescue ::Ai::BaseService::ApiError => e
    Rails.logger.warn("AI Analysis failed for activity #{activity_id}: #{e.message}")
  end
end
