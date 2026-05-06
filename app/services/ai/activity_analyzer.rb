# frozen_string_literal: true

module Ai
  class ActivityAnalyzer < BaseService
    def initialize(activity, user)
      @activity = activity
      @user = user
    end

    def call
      activity_data = Export::ActivityJsonExporter.new(@activity).call
      context = build_context

      messages = [
        { role: "user",
          content: "#{context}\n\nVoici les données de la séance :\n```json\n#{JSON.pretty_generate(activity_data)}\n```" }
      ]

      analysis = call_api(
        system: load_prompt("activity_analyzer"),
        messages: messages,
        max_tokens: 3000
      )

      @activity.update!(ai_analysis: analysis, ai_analyzed_at: Time.current)
      analysis
    end

    private

    def build_context
      parts = []
      parts << "## Profil coureur"
      parts << "#{@user.full_name}, #{@user.age} ans, #{@user.gender}"
      parts << "FC max estimée : #{@user.estimated_max_hr} bpm"

      resting = @user.user_metrics.by_type(:resting_hr).recent_first.first
      parts << "FC repos : #{resting.value.to_i} bpm" if resting

      vma = @user.user_metrics.by_type(:vma_test).recent_first.first
      parts << "VMA : #{vma.value} km/h" if vma

      if @activity.planned_session
        parts << "\n## Séance prévue"
        parts << "Objectif : #{@activity.planned_session.title}"
        if @activity.planned_session.description.present?
          parts << "Description : #{@activity.planned_session.description}"
        end
        if @activity.planned_session.target_distance_meters
          parts << "Distance cible : #{(@activity.planned_session.target_distance_meters / 1000.0).round(1)} km"
        end
        if @activity.planned_session.target_duration_formatted
          parts << "Durée cible : #{@activity.planned_session.target_duration_formatted}"
        end
        if @activity.planned_session.target_pace_formatted
          parts << "Allure cible : #{@activity.planned_session.target_pace_formatted}"
        end
      end

      parts.join("\n")
    end
  end
end
