# frozen_string_literal: true

class CreateDailyJournals < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_journals do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.integer :mood
      t.integer :sleep_quality
      t.decimal :sleep_hours, precision: 3, scale: 1
      t.integer :fatigue
      t.integer :soreness
      t.text :comment

      t.timestamps
    end

    add_index :daily_journals, [:user_id, :date], unique: true
  end
end
