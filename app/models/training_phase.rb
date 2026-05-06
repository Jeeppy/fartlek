# frozen_string_literal: true

class TrainingPhase < ApplicationRecord
  belongs_to :user
  belongs_to :competition, optional: true

  enum :phase_type, {
    preparation_generale: 0,
    preparation_specifique: 1,
    pre_competition: 2,
    competition: 3,
    recuperation: 4,
    foncier: 5,
    affutage: 6
  }

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_after_start

  scope :current, -> { where("start_date <= ? AND end_date >= ?", Date.current, Date.current) }
  scope :ordered, -> { order(:start_date) }
  scope :for_month, lambda { |date|
    where("start_date <= ? AND end_date >= ?", date.end_of_month, date.beginning_of_month)
  }

  PHASE_COLORS = {
    "preparation_generale" => "#3B82F6",
    "preparation_specifique" => "#8B5CF6",
    "pre_competition" => "#F59E0B",
    "competition" => "#EF4444",
    "recuperation" => "#22C55E",
    "foncier" => "#06B6D4",
    "affutage" => "#EC4899"
  }.freeze

  def duration_days
    (end_date - start_date).to_i + 1
  end

  def covers_date?(date)
    date >= start_date && date <= end_date
  end

  private

  def end_after_start
    return unless start_date && end_date

    errors.add(:end_date, "doit être après la date de début") if end_date < start_date
  end
end
