# frozen_string_literal: true

module Ai
  # Analyzes a training activity using AI and saves the result.
  class ActivityAnalyzer < BaseService
    def initialize(activity, user)
      super()
      @activity = activity
      @user = user
    end

    def call
      analysis = call_api(
        system: load_prompt("activity_analyzer"),
        messages: build_messages,
        max_tokens: 1500
      )

      @activity.update!(ai_analysis: analysis, ai_analyzed_at: Time.current)
      analysis
    end

    private

    def build_messages
      content = [
        build_context,
        "Voici les données de la séance :",
        "```json",
        JSON.pretty_generate(activity_data),
        "```"
      ].join("\n\n")

      [{ role: "user", content: content }]
    end

    def activity_data
      Export::ActivityJsonExporter.new(@activity).call
    end

    def build_context
      [
        profile_context,
        planned_session_context
      ].compact.join("\n")
    end

    def profile_context
      parts = ["## Profil coureur"]
      parts << "#{@user.full_name}, #{@user.age} ans, #{@user.gender}"
      parts << "FC max estimée : #{@user.estimated_max_hr} bpm"
      parts << resting_hr_line
      parts << vma_line
      parts.compact.join("\n")
    end

    def resting_hr_line
      resting = @user.user_metrics.by_type(:resting_hr).recent_first.first
      "FC repos : #{resting.value.to_i} bpm" if resting
    end

    def vma_line
      vma = @user.user_metrics.by_type(:vma_test).recent_first.first
      "VMA : #{vma.value} km/h" if vma
    end

    def planned_session_context
      ps = @activity.planned_session
      return nil unless ps

      (["\n## Séance prévue", "Objectif : #{ps.title}"] + planned_session_details(ps)).join("\n")
    end

    def planned_session_details(session)
      [
        (session.description.present? ? "Description : #{session.description}" : nil),
        (
          "Distance cible : #{(session.target_distance_meters / 1000.0).round(1)} km" if session.target_distance_meters
        ),
        (session.target_duration_formatted ? "Durée cible : #{session.target_duration_formatted}" : nil),
        (session.target_pace_formatted ? "Allure cible : #{session.target_pace_formatted}" : nil),
        (session.target_rpe ? "RPE cible : #{session.target_rpe}" : nil)
      ].compact
    end
  end
end
