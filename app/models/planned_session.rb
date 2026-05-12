# frozen_string_literal: true

class PlannedSession < ApplicationRecord
  include SportIcon

  belongs_to :user
  belongs_to :activity, optional: true

  enum :sport, { running: 0, cycling: 1, walking: 2, swimming: 3, ppg: 4 }

  validates :date, presence: true
  validates :title, presence: true
  validates :sport, presence: true
  validates :target_rpe, numericality: { in: 1..10 }, allow_nil: true

  scope :for_week, ->(date) { where(date: date.all_week) }
  scope :for_date, ->(date) { where(date: date) }
  scope :ordered, -> { order(:date) }

  def completed?
    completed || activity.present?
  end

  def target_duration_formatted
    return unless target_duration_seconds

    hours = target_duration_seconds / 3600
    minutes = (target_duration_seconds % 3600) / 60
    if hours.positive?
      format("%<h>dh%<m>02d", h: hours, m: minutes)
    else
      format("%<m>dmin", m: minutes)
    end
  end

  def target_pace_formatted
    return unless target_pace_seconds_per_km

    "#{target_pace_seconds_per_km / 60}:#{format('%02d', target_pace_seconds_per_km % 60)} /km"
  end
end
