# frozen_string_literal: true

class Equipment < ApplicationRecord
  belongs_to :user
  has_many :activities, dependent: :nullify

  enum :equipment_type, { shoes: 0, bike: 1, other: 2 }

  validates :name, presence: true
  validates :equipment_type, presence: true

  scope :active, -> { where(retired: false) }
  scope :retired, -> { where(retired: true) }
  scope :ordered, -> { order(:name) }

  def total_distance_meters
    initial_distance_meters + activities.sum(:distance_meters).to_i
  end

  def total_distance_km
    (total_distance_meters / 1000.0).round(1)
  end

  def usage_percent
    return nil unless max_distance_meters&.positive?

    ((total_distance_meters.to_f / max_distance_meters) * 100).round(1)
  end

  def needs_replacement?
    return false unless max_distance_meters&.positive?

    total_distance_meters >= max_distance_meters
  end
end
