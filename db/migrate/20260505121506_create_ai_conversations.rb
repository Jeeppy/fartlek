# frozen_string_literal: true

class CreateAiConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_conversations do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :conversation_type, null: false, default: 0
      t.date :week_start_date
      t.jsonb :messages, null: false, default: []

      t.timestamps
    end

    add_index :ai_conversations, [:user_id, :conversation_type, :week_start_date], unique: true,
              name: "idx_ai_conversations_unique"
  end
end
