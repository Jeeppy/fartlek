# frozen_string_literal: true

class WeeklyJournal < ApplicationRecord
  belongs_to :user

  validates :week_start_date, presence: true, uniqueness: { scope: :user_id }
  validates :pleasure, inclusion: { in: 1..5 }, allow_nil: true
  validates :difficulty, inclusion: { in: 1..5 }, allow_nil: true
  validates :fatigue, inclusion: { in: 1..5 }, allow_nil: true
  validate :week_start_date_is_monday

  scope :chronological, -> { order(week_start_date: :desc) }

  private

  def week_start_date_is_monday
    return unless week_start_date

    errors.add(:week_start_date, "doit être un lundi") unless week_start_date.monday?
  end
end
