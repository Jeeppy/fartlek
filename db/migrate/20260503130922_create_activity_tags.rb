# frozen_string_literal: true

class CreateActivityTags < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_tags do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :color, null: false, default: "#6366f1"

      t.timestamps
    end

    add_index :activity_tags, [:user_id, :name], unique: true
  end
end
