# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # ─── Enums ────────────────────────────────────────────
  enum :gender, { male: 0, female: 1, other: 2 }

  # ─── Validations ──────────────────────────────────────
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :gender, presence: true
  validates :date_of_birth, presence: true
  validate :date_of_birth_in_past, if: :date_of_birth

  # ─── Instance methods ─────────────────────────────────
  def full_name
    "#{first_name} #{last_name}"
  end

  def age
    return unless date_of_birth

    now = Time.current.to_date
    age = now.year - date_of_birth.year
    age -= 1 if now < date_of_birth + age.years
    age
  end

  def admin?
    admin
  end

  private

  def date_of_birth_in_past
    errors.add(:date_of_birth, :in_future) if date_of_birth >= Date.current
  end
end
