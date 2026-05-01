# frozen_string_literal: true

class UserMetric < ApplicationRecord
  belongs_to :user

  enum :metric_type, {
    weight: 0,
    resting_hr: 1,
    vma_test: 2,
    vo2max: 3,
    body_fat: 4
  }

  validates :recorded_on, presence: true
  validates :metric_type, presence: true
  validates :value, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true

  scope :chronological, -> { order(recorded_on: :asc) }
  scope :recent_first, -> { order(recorded_on: :desc) }
  scope :by_type, ->(type) { where(metric_type: type) }

  UNITS = {
    "weight" => "kg",
    "resting_hr" => "bpm",
    "vma_test" => "km/h",
    "vo2max" => "ml/kg/min",
    "body_fat" => "%"
  }.freeze

  def self.default_unit(type)
    UNITS[type.to_s]
  end
end
