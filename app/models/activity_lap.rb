# frozen_string_literal: true

class ActivityLap < ApplicationRecord
  belongs_to :activity

  validates :lap_number, presence: true, numericality: { greater_than: 0 }

  scope :ordered, -> { order(:lap_number) }

  def pace_formatted
    return unless average_pace_seconds_per_km

    minutes = average_pace_seconds_per_km / 60
    secs = average_pace_seconds_per_km % 60
    format("%<m>d:%<s>02d /km", m: minutes, s: secs)
  end
end
