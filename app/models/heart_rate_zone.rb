# frozen_string_literal: true

class HeartRateZone < ApplicationRecord
  belongs_to :user

  validates :zone_number, presence: true,
                          uniqueness: { scope: :user_id },
                          inclusion: { in: 1..5 }
  validates :name, presence: true
  validates :min_bpm, presence: true, numericality: { greater_than: 0 }
  validates :max_bpm, presence: true, numericality: { greater_than: 0 }
  validate :max_greater_than_min

  scope :ordered, -> { order(:zone_number) }

  DEFAULTS = [
    { zone_number: 1, name: "Récupération", color: "#3B82F6" },
    { zone_number: 2, name: "Endurance", color: "#22C55E" },
    { zone_number: 3, name: "Tempo", color: "#EAB308" },
    { zone_number: 4, name: "Seuil", color: "#F97316" },
    { zone_number: 5, name: "VO2max", color: "#EF4444" }
  ].freeze

  ZONE_RANGES = [
    [0.50, 0.60],
    [0.60, 0.70],
    [0.70, 0.80],
    [0.80, 0.90],
    [0.90, 1.00]
  ].freeze

  def self.generate_defaults(user)
    DEFAULTS.each_with_index do |default, index|
      create_zone(user, default, ZONE_RANGES[index])
    end
  end

  def self.create_zone(user, default, range)
    max_hr = user.estimated_max_hr
    user.heart_rate_zones.find_or_create_by!(zone_number: default[:zone_number]) do |zone|
      zone.name = default[:name]
      zone.color = default[:color]
      zone.min_bpm = (max_hr * range[0]).round
      zone.max_bpm = (max_hr * range[1]).round
    end
  end

  private_class_method :create_zone

  private

  def max_greater_than_min
    return unless min_bpm && max_bpm

    errors.add(:max_bpm, "doit être supérieur au minimum") if max_bpm <= min_bpm
  end
end
