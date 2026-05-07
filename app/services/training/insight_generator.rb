# frozen_string_literal: true

module Training
  class InsightGenerator
    def initialize(fitness, weekly)
      @fitness = fitness
      @weekly = weekly
    end

    def call
      insights = []
      insights << volume_insight
      insights << trend_insight
      insights << recovery_insight
      insights.compact
    end

    private

    def trend_insight
      return nil unless @fitness.is_a?(Array) && @fitness.size >= 7

      recent_tsb = @fitness.last(7).pluck(:tsb)
      trend = recent_tsb.last - recent_tsb.first

      if trend > 5
        "Forme en progression sur 7 jours."
      elsif trend < -10
        "Fatigue en accumulation. Pense à un jour de repos."
      end
    end

    def volume_insight
      current = @weekly[:current]
      previous = @weekly[:previous]

      if current[:count].zero?
        "Aucune séance cette semaine. Reprise progressive recommandée."
      elsif previous[:distance_km].positive?
        delta = ((current[:distance_km] - previous[:distance_km]).to_f / previous[:distance_km] * 100).round(0)
        if delta > 15
          "Volume en hausse de #{delta}% vs semaine dernière."
        elsif delta < -30
          "Volume réduit de #{delta.abs}%. Semaine de récupération."
        end
      end
    end

    def recovery_insight
      return nil unless @fitness.is_a?(Array)

      last = @fitness.last
      return unless last[:atl] > last[:ctl] * 1.5

      "Fatigue aiguë bien supérieure à ta fitness. Allège la charge."
    end
  end
end
