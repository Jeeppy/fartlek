# frozen_string_literal: true

# Scores a training week based on rest, quality, compliance, and RPE.
module Training
  class WeekScorer
    def initialize(analyzer)
      @analyzer = analyzer
      @stats = analyzer.stats
    end

    def call
      score = 0
      warnings = []

      score, warnings = evaluate_rest(score, warnings)
      score, warnings = evaluate_quality(score, warnings)
      score, warnings = evaluate_compliance(score, warnings)
      score, warnings = evaluate_rpe(score, warnings)

      { level: classify(score), score: score, warnings: warnings }
    end

    private

    def evaluate_rest(score, warnings)
      if @analyzer.current_week? || @stats[:rest_days] >= 1
        [score + 1, warnings]
      else
        [score, warnings + ["Aucun jour de repos"]]
      end
    end

    def evaluate_quality(score, warnings)
      if @stats[:quality_done] <= 2
        [score + 1, warnings]
      else
        [score, warnings + ["#{@stats[:quality_done]} séances intensité (max 2 recommandé)"]]
      end
    end

    def evaluate_compliance(score, warnings)
      compliance = @stats[:compliance]
      return [score + 1, warnings] if compliance.nil? || compliance >= 80

      if compliance < 50
        [score, warnings + ["Faible adhérence au plan (#{compliance}%)"]]
      else
        [score, warnings]
      end
    end

    def evaluate_rpe(score, warnings)
      avg_rpe = @stats[:avg_rpe]
      return [score + 1, warnings] if avg_rpe.nil? || avg_rpe <= 6

      if avg_rpe > 7
        [score, warnings + ["RPE moyen élevé (#{avg_rpe})"]]
      else
        [score, warnings]
      end
    end

    def classify(score)
      case score
      when 4 then :balanced
      when 2..3 then :loaded
      else :risky
      end
    end
  end
end
