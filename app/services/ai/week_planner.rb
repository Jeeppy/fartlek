# frozen_string_literal: true

module Ai
  # Plans training weeks using AI with persistent conversation history.
  class WeekPlanner < BaseService
    def initialize(user)
      super()
      @user = user
    end

    def call(message: nil)
      conversation = find_or_create_conversation
      add_message_to_conversation(conversation, message)

      response = call_api(
        system: load_prompt("week_planner"),
        messages: conversation.messages,
        max_tokens: 3000
      )

      conversation.add_message("assistant", response)
      response
    end

    def conversation
      find_or_create_conversation
    end

    private

    def find_or_create_conversation
      @user.ai_conversations.find_or_create_by!(
        conversation_type: :planning,
        week_start_date: Date.current.next_week
      )
    end

    def add_message_to_conversation(conversation, message)
      if conversation.messages.empty?
        initial_message = "#{build_context}\n\n" \
                          "Planifie ma semaine d'entraînement à venir (#{next_week_label})."
        conversation.add_message("user", initial_message)
      elsif message.present?
        conversation.add_message("user", message)
      end
    end

    def build_context
      WeekContextBuilder.new(@user).call
    end

    def next_week_label
      start = Date.current.next_week
      "du #{start.strftime('%d/%m')} au #{(start + 6.days).strftime('%d/%m/%Y')}"
    end
  end
end
