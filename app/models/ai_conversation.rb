# frozen_string_literal: true

class AiConversation < ApplicationRecord
  belongs_to :user

  enum :conversation_type, { planning: 0, coaching: 1 }

  validates :conversation_type, presence: true
  validates :week_start_date, uniqueness: { scope: [:user_id, :conversation_type] }, if: :planning?

  scope :for_week, ->(date) { where(week_start_date: date.beginning_of_week) }

  def add_message(role, content)
    self.messages = (messages || []) + [{ "role" => role, "content" => content }]
    save!
  end
end
