# frozen_string_literal: true

class PaceZone < ApplicationRecord
  belongs_to :user

  validates :zone_number, presence: true,
                          uniqueness: { scope: :user_id },
                          inclusion: { in: 1..7 }
  validates :name, presence: true
  validates :min_pace_seconds_per_km, presence: true, numericality: { greater_than: 0 }
  validates :max_pace_seconds_per_km, presence: true, numericality: { greater_than: 0 }
  validate :max_slower_than_min

  scope :ordered, -> { order(:zone_number) }

  DEFAULTS = [
    { zone_number: 1, name: "Footing lent", color: "#3B82F6", min: 390, max: 450 },
    { zone_number: 2, name: "Endurance fondamentale", color: "#22C55E", min: 345, max: 390 },
    { zone_number: 3, name: "Allure marathon", color: "#84CC16", min: 315, max: 345 },
    { zone_number: 4, name: "Allure semi", color: "#EAB308", min: 295, max: 315 },
    { zone_number: 5, name: "Allure 10k", color: "#F97316", min: 270, max: 295 },
    { zone_number: 6, name: "Allure 5k", color: "#EF4444", min: 250, max: 270 },
    { zone_number: 7, name: "VMA", color: "#DC2626", min: 210, max: 250 }
  ].freeze

  def self.generate_defaults(user)
    DEFAULTS.each do |default|
      user.pace_zones.find_or_create_by!(zone_number: default[:zone_number]) do |zone|
        zone.name = default[:name]
        zone.color = default[:color]
        zone.min_pace_seconds_per_km = default[:min]
        zone.max_pace_seconds_per_km = default[:max]
      end
    end
  end

  def min_pace_formatted
    format_pace(min_pace_seconds_per_km)
  end

  def max_pace_formatted
    format_pace(max_pace_seconds_per_km)
  end

  private

  def max_slower_than_min
    return unless min_pace_seconds_per_km && max_pace_seconds_per_km

    return unless max_pace_seconds_per_km <= min_pace_seconds_per_km

    errors.add(:max_pace_seconds_per_km, "doit être plus lent que le minimum (valeur plus élevée)")
  end

  def format_pace(seconds)
    return unless seconds

    "#{seconds / 60}:#{format('%02d', seconds % 60)}"
  end
end
