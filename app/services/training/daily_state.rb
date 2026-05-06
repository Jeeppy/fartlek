# frozen_string_literal: true

module Training
  class DailyState
    def initialize(fitness, journal)
      @fitness = fitness
      @journal = journal
    end

    def call
      tsb = @fitness[:tsb]
      fatigue_score = journal_fatigue

      if fatigue_score && fatigue_score >= 4
        fatigue_state("Fatigue ressentie élevée.", "Séance légère ou repos recommandé")
      elsif tsb > 10
        peak_state
      elsif tsb > 5
        good_state
      elsif tsb > -10
        moderate_state
      elsif tsb > -20
        fatigue_state("Charge accumulée.", "Privilégie l'endurance fondamentale")
      else
        overreach_state
      end
    end

    private

    def journal_fatigue
      return nil unless @journal

      scores = [@journal.fatigue, @journal.soreness].compact
      return nil if scores.empty?

      scores.sum.to_f / scores.size
    end

    def peak_state
      {
        title: "Forme optimale",
        emoji: "🔵",
        message: "Pic de forme. Idéal pour une compétition ou un test.",
        action: "Séance de qualité recommandée",
        color: "text-blue-400",
        recommendation: :quality
      }
    end

    def good_state
      {
        title: "Bonne forme",
        emoji: "🟢",
        message: "Bien récupéré, prêt pour du qualitatif.",
        action: "Séance de qualité possible",
        color: "text-green-400",
        recommendation: :quality
      }
    end

    def moderate_state
      {
        title: "Charge modérée",
        emoji: "🟠",
        message: "Charge en cours d'assimilation.",
        action: "Endurance fondamentale ou repos actif",
        color: "text-orange-400",
        recommendation: :moderate
      }
    end

    def fatigue_state(message = nil, action = nil)
      {
        title: "Fatigue élevée",
        emoji: "🔴",
        message: message || "Charge accumulée importante.",
        action: action || "Repos ou séance très légère",
        color: "text-red-400",
        recommendation: :easy
      }
    end

    def overreach_state
      {
        title: "Surcharge",
        emoji: "⚠️",
        message: "Risque de surentraînement.",
        action: "Repos impératif",
        color: "text-red-500",
        recommendation: :rest
      }
    end
  end
end
