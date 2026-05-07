# frozen_string_literal: true

module Ai
  # Builds context for the week planner AI prompt.
  class WeekContextBuilder
    def initialize(user)
      @user = user
    end

    def call
      [
        profile_context,
        pace_zones_context,
        recent_weeks_context,
        current_week_context,
        fitness_context,
        competitions_context,
        phase_context,
        previous_plan_context
      ].compact.join("\n")
    end

    private

    def profile_context
      parts = ["## Profil coureur", profile_line]
      parts << "FC max estimée : #{@user.estimated_max_hr} bpm"
      parts << resting_hr_line
      parts << vma_line
      parts.compact.join("\n")
    end

    def profile_line
      "#{@user.full_name}, #{@user.age} ans, #{@user.gender}"
    end

    def resting_hr_line
      resting = @user.user_metrics.by_type(:resting_hr).recent_first.first
      "FC repos : #{resting.value.to_i} bpm" if resting
    end

    def vma_line
      vma = @user.user_metrics.by_type(:vma_test).recent_first.first
      "VMA : #{vma.value} km/h" if vma
    end

    def pace_zones_context
      zones = @user.pace_zones.ordered
      return nil unless zones.any?

      parts = ["\n## Zones d'allure"]
      zones.each { |z| parts << "- #{z.name} : #{z.max_pace_formatted} à #{z.min_pace_formatted} /km" }
      parts.join("\n")
    end

    def recent_weeks_context
      RecentWeeksContext.new(@user).call
    end

    def current_week_context
      planned = @user.planned_sessions.for_week(Date.current).ordered
      return nil unless planned.any?

      parts = ["\n## Séances planifiées cette semaine"]
      planned.each { |plan| parts << format_planned(plan) }
      parts.join("\n")
    end

    def format_planned(plan)
      status = plan.completed? ? "✅" : "⬜"
      line = "- #{plan.date.strftime('%A %d/%m')} #{status} #{plan.title}"
      line += " — #{(plan.target_distance_meters / 1000.0).round(1)}km" if plan.target_distance_meters
      line += ", #{plan.target_duration_formatted}" if plan.target_duration_formatted
      line
    end

    def fitness_context
      fitness = ::TrainingLoad::FitnessCalculator.new(@user).call.last
      return nil unless fitness

      [
        "\n## Charge actuelle",
        "CTL (fitness) : #{fitness[:ctl]}",
        "ATL (fatigue) : #{fitness[:atl]}",
        "TSB (forme) : #{fitness[:tsb].round(1)}"
      ].join("\n")
    end

    def competitions_context
      competitions = @user.competitions.upcoming.limit(5)
      return nil unless competitions.any?

      parts = ["\n## Compétitions à venir"]
      competitions.each { |comp| parts << format_competition(comp) }
      parts.join("\n")
    end

    def format_competition(comp)
      line = "- #{comp.name} (#{comp.principal? ? 'Objectif A' : 'Objectif B'})"
      line += " — #{comp.date.strftime('%d/%m/%Y')} — J-#{comp.days_until}"
      line += " — #{(comp.target_distance_meters / 1000.0).round(1)} km" if comp.target_distance_meters
      line
    end

    def phase_context
      phase = @user.training_phases.current.first
      return nil unless phase

      "\n## Phase : #{phase.name} (#{phase.phase_type.humanize})"
    end

    def previous_plan_context
      prev = @user.ai_conversations.find_by(
        conversation_type: :planning,
        week_start_date: Date.current.beginning_of_week
      )
      return nil unless prev&.messages&.any?

      last_plan = prev.messages.reverse.find { |msg| msg["role"] == "assistant" }
      return nil unless last_plan

      "\n## Plan de la semaine en cours (pour continuité)\n#{last_plan['content']}"
    end
  end
end
