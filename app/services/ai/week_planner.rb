# frozen_string_literal: true

module Ai
  class WeekPlanner < BaseService
    def initialize(user)
      @user = user
    end

    def call(message: nil)
      conversation = find_or_create_conversation
      context = build_context

      if conversation.messages.empty?
        conversation.add_message("user",
                                 "#{context}\n\nPlanifie ma semaine d'entraînement à venir (#{next_week_label}).")
      elsif message.present?
        conversation.add_message("user", message)
      end

      response = call_api(
        system: load_prompt("week_planner"),
        messages: conversation.messages,
        max_tokens: 3000
      )

      conversation.add_message("assistant", response)
      response
    end

    def conversation
      find_or_create_conversation
    end

    private

    def find_or_create_conversation
      @user.ai_conversations.find_or_create_by!(
        conversation_type: :planning,
        week_start_date: Date.current.next_week
      )
    end

    def next_week_label
      start = Date.current.next_week
      "du #{start.strftime('%d/%m')} au #{(start + 6.days).strftime('%d/%m/%Y')}"
    end

    def build_context
      parts = []

      # Profil
      parts << "## Profil coureur"
      parts << "#{@user.full_name}, #{@user.age} ans, #{@user.gender}"
      parts << "FC max estimée : #{@user.estimated_max_hr} bpm"

      resting = @user.user_metrics.by_type(:resting_hr).recent_first.first
      parts << "FC repos : #{resting.value.to_i} bpm" if resting

      vma = @user.user_metrics.by_type(:vma_test).recent_first.first
      parts << "VMA : #{vma.value} km/h" if vma

      # Zones
      zones = @user.pace_zones.ordered
      if zones.any?
        parts << "\n## Zones d'allure"
        zones.each { |z| parts << "- #{z.name} : #{z.max_pace_formatted} à #{z.min_pace_formatted} /km" }
      end

      # 4 dernières semaines
      parts << "\n## 4 dernières semaines"
      4.downto(1).each do |i|
        week_date = Date.current - i.weeks
        activities = @user.activities.for_week(week_date).includes(:activity_tags)
        km = activities.sum { |a| a.distance_km || 0 }.round(1)
        hours = (activities.sum { |a| a.duration_seconds || 0 } / 3600.0).round(1)
        parts << "\n### S-#{i} (#{week_date.beginning_of_week.strftime('%d/%m')})"
        parts << "#{activities.count} séances, #{km} km, #{hours}h"
        activities.each do |a|
          tags = a.activity_tags.pluck(:name).join(", ")
          line = "- #{a.performed_at.strftime('%A')} : #{a.title || a.sport.humanize}"
          line += " — #{a.distance_km}km" if a.distance_km
          line += ", #{a.duration_formatted}" if a.duration_formatted
          line += ", #{a.pace_formatted}" if a.pace_formatted
          line += " [#{tags}]" if tags.present?
          parts << line
        end

        journal = @user.weekly_journals.find_by(week_start_date: week_date.beginning_of_week)
        next unless journal

        if journal.pleasure
          parts << "Bilan : plaisir #{journal.pleasure}/5, difficulté #{journal.difficulty}/5, fatigue #{journal.fatigue}/5"
        end
        parts << "Note : #{journal.comment}" if journal.comment.present?
      end

      # Semaine en cours — séances planifiées
      planned = @user.planned_sessions.for_week(Date.current).ordered
      if planned.any?
        parts << "\n## Séances planifiées cette semaine"
        planned.each do |p|
          status = p.completed? ? "✅" : "⬜"
          line = "- #{p.date.strftime('%A %d/%m')} #{status} #{p.title}"
          line += " — #{(p.target_distance_meters / 1000.0).round(1)}km" if p.target_distance_meters
          line += ", #{p.target_duration_formatted}" if p.target_duration_formatted
          parts << line
        end
      end

      # Charge
      fitness = ::TrainingLoad::FitnessCalculator.new(@user).call.last
      if fitness
        parts << "\n## Charge actuelle"
        parts << "CTL (fitness) : #{fitness[:ctl]}"
        parts << "ATL (fatigue) : #{fitness[:atl]}"
        parts << "TSB (forme) : #{fitness[:tsb].round(1)}"
      end

      # Compétitions
      competitions = @user.competitions.upcoming.limit(5)
      if competitions.any?
        parts << "\n## Compétitions à venir"
        competitions.each do |c|
          line = "- #{c.name} (#{c.principal? ? 'Objectif A' : 'Objectif B'})"
          line += " — #{c.date.strftime('%d/%m/%Y')} — J-#{c.days_until}"
          line += " — #{(c.target_distance_meters / 1000.0).round(1)} km" if c.target_distance_meters
          parts << line
        end
      end

      # Phase
      phase = @user.training_phases.current.first
      parts << "\n## Phase : #{phase.name} (#{phase.phase_type.humanize})" if phase

      # Historique planning précédent
      prev = @user.ai_conversations.find_by(
        conversation_type: :planning,
        week_start_date: Date.current.beginning_of_week
      )
      if prev&.messages&.any?
        last_plan = prev.messages.select { |m| m["role"] == "assistant" }.last
        if last_plan
          parts << "\n## Plan de la semaine en cours (pour continuité)"
          parts << last_plan["content"]
        end
      end

      parts.join("\n")
    end
  end
end
