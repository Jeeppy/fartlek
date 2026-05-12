# frozen_string_literal: true

module SportIcon
  extend ActiveSupport::Concern

  SPORT_ICONS = {
    "running" => "🏃",
    "cycling" => "🚴",
    "walking" => "🚶",
    "swimming" => "🏊",
    "ppg" => "💪"
  }.freeze

  def sport_icon
    SPORT_ICONS.fetch(sport, "🏃")
  end
end
