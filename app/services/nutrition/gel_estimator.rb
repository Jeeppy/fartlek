# frozen_string_literal: true

module Nutrition
  class GelEstimator
    # Règles standard nutrition effort :
    # - < 45min : rien
    # - 45min-1h15 : 0-1 gel selon intensité
    # - > 1h15 : 1 gel toutes les 30-45min
    # - Compétition : +1 gel anticipation
    # Un gel ≈ 20-25g de glucides

    GEL_CARBS = 25 # grammes par gel
    CARBS_PER_HOUR_EASY = 30 # g/h en EF
    CARBS_PER_HOUR_MODERATE = 45 # g/h en tempo/seuil
    CARBS_PER_HOUR_HARD = 60 # g/h en compétition/VMA
    CARBS_PER_HOUR_ULTRA = 90 # g/h marathon+

    def initialize(activity)
      @activity = activity
    end

    def call
      return nil unless @activity.duration_seconds
      return { gels: 0, carbs_g: 0, hydration_ml: 0, note: "Pas de ravitaillement nécessaire" } if duration_minutes < 45

      {
        gels: estimated_gels,
        carbs_g: estimated_carbs,
        hydration_ml: estimated_hydration,
        note: recommendation
      }
    end

    private

    def duration_minutes
      @activity.duration_seconds / 60.0
    end

    def duration_hours
      duration_minutes / 60.0
    end

    def intensity
      rpe = @activity.rpe || 5
      if rpe <= 4
        :easy
      elsif rpe <= 6
        :moderate
      elsif rpe <= 8
        :hard
      else
        :race
      end
    end

    def carbs_per_hour
      case intensity
      when :easy then CARBS_PER_HOUR_EASY
      when :moderate then CARBS_PER_HOUR_MODERATE
      when :hard then CARBS_PER_HOUR_HARD
      when :race then CARBS_PER_HOUR_ULTRA
      end
    end

    def estimated_carbs
      (carbs_per_hour * duration_hours).round(0)
    end

    def estimated_gels
      (estimated_carbs.to_f / GEL_CARBS).ceil
    end

    def estimated_hydration
      # ~500ml/h en conditions normales, +200ml si chaud
      (500 * duration_hours).round(0)
    end

    def recommendation
      case duration_minutes
      when 0..44
        "Pas de ravitaillement nécessaire"
      when 45..75
        "1 gel en fin de séance si intensité élevée, sinon eau suffit"
      when 76..120
        "#{estimated_gels} gel(s) — 1 toutes les 40min. Boire 400-600ml/h"
      else
        "#{estimated_gels} gel(s) — 1 toutes les 30min. Boire 500-800ml/h. Alterner gel et boisson isotonique"
      end
    end
  end
end
