# frozen_string_literal: true

class DailyJournal < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: :user_id }
  validates :mood, inclusion: { in: 1..5 }, allow_nil: true
  validates :sleep_quality, inclusion: { in: 1..5 }, allow_nil: true
  validates :sleep_hours, numericality: { greater_than: 0, less_than: 24 }, allow_nil: true
  validates :fatigue, inclusion: { in: 1..5 }, allow_nil: true
  validates :soreness, inclusion: { in: 1..5 }, allow_nil: true

  scope :chronological, -> { order(date: :desc) }
  scope :for_date, ->(date) { find_by(date: date) }
  scope :for_week, ->(date) { where(date: date.all_week) }

  MOOD_EMOJIS = { 1 => "😫", 2 => "😕", 3 => "😐", 4 => "🙂", 5 => "😄" }.freeze

  def mood_emoji
    MOOD_EMOJIS[mood]
  end
end
