# frozen_string_literal: true

class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :equipment, optional: true
  has_many :activity_laps, dependent: :destroy
  has_many :activity_taggings, dependent: :destroy
  has_many :activity_tags, through: :activity_taggings
  has_one :planned_session, dependent: :nullify

  # ─── Enums ────────────────────────────────────────────
  enum :sport, { running: 0, cycling: 1, walking: 2, swimming: 3, ppg: 4 }
  enum :feeling, { terrible: 0, bad: 1, ok: 2, good: 3, great: 4 }

  # ─── Validations ──────────────────────────────────────
  validates :sport, presence: true
  validates :performed_at, presence: true
  validates :rpe, inclusion: { in: 1..10 }, allow_nil: true
  validates :duration_seconds, numericality: { greater_than: 0 }, allow_nil: true
  validates :distance_meters, numericality: { greater_than: 0 }, allow_nil: true
  validates :strava_id, uniqueness: true, allow_nil: true

  # ─── Scopes ───────────────────────────────────────────
  scope :chronological, -> { order(performed_at: :desc) }
  scope :by_sport, ->(sport) { where(sport: sport) }
  scope :for_date, ->(date) { where(performed_at: date.to_time.all_day) }
  scope :for_week, ->(date) { where(performed_at: date.to_time.all_week) }
  scope :for_month, ->(date) { where(performed_at: date.to_time.all_month) }
  scope :for_year, ->(date) { where(performed_at: date.to_time.all_year) }

  # ─── Instance methods ─────────────────────────────────
  def distance_km
    return unless distance_meters

    (distance_meters / 1000.0).round(2)
  end

  def duration_formatted
    return unless duration_seconds

    hours = duration_seconds / 3600
    minutes = (duration_seconds % 3600) / 60
    secs = duration_seconds % 60

    if hours > 0
      format("%<h>dh%<m>02d", h: hours, m: minutes)
    else
      format("%<m>d:%<s>02d", m: minutes, s: secs)
    end
  end

  def pace_formatted
    return unless average_pace_seconds_per_km

    minutes = average_pace_seconds_per_km / 60
    secs = average_pace_seconds_per_km % 60
    format("%<m>d:%<s>02d /km", m: minutes, s: secs)
  end

  def sport_icon
    case sport
    when "running"  then "🏃"
    when "cycling"  then "🚴"
    when "walking"  then "🚶"
    when "swimming" then "🏊"
    when "ppg"      then "💪"
    end
  end

  def from_strava?
    strava_id.present?
  end

  def trimp(user)
    @trimp ||= ::TrainingLoad::StressCalculator.new(self, user).call
  end

  def foster_load
    return nil unless rpe && duration_seconds

    (rpe * (duration_seconds / 60.0)).round(0)
  end

  def analyzed?
    ai_analysis.present?
  end

  def nutrition_estimate
    return nil unless running? || cycling? || walking?

    @nutrition_estimate ||= ::Nutrition::GelEstimator.new(self).call
  end
end
