# frozen_string_literal: true

class Competition < ApplicationRecord
  belongs_to :user
  has_many :training_phases, dependent: :nullify

  enum :priority, { principal: 0, secondaire: 1 }
  enum :sport, { running: 0, cycling: 1, walking: 2, swimming: 3 }, prefix: :sport

  validates :name, presence: true
  validates :date, presence: true
  validates :priority, presence: true

  scope :upcoming, -> { where("date >= ?", Date.current).order(:date) }
  scope :past, -> { where("date < ?", Date.current).order(date: :desc) }
  scope :principal, -> { where(priority: :principal) }
  scope :secondaire, -> { where(priority: :secondaire) }

  def days_until
    return nil if date < Date.current

    (date - Date.current).to_i
  end

  def target_pace_formatted
    return unless target_pace_seconds_per_km

    "#{target_pace_seconds_per_km / 60}:#{format('%02d', target_pace_seconds_per_km % 60)}"
  end

  def target_time_formatted
    return unless target_time_seconds

    hours = target_time_seconds / 3600
    minutes = (target_time_seconds % 3600) / 60
    seconds = target_time_seconds % 60
    if hours > 0
      format("%<h>dh%<m>02d:%<s>02d", h: hours, m: minutes, s: seconds)
    else
      format("%<m>d:%<s>02d", m: minutes, s: seconds)
    end
  end

  def result_pace_formatted
    return unless result_pace_seconds_per_km

    "#{result_pace_seconds_per_km / 60}:#{format('%02d', result_pace_seconds_per_km % 60)}"
  end
end
