# frozen_string_literal: true

class CreatePlannedSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :planned_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :activity, foreign_key: true
      t.date :date, null: false
      t.integer :sport, null: false, default: 0
      t.string :title, null: false
      t.text :description
      t.integer :target_duration_seconds
      t.integer :target_distance_meters
      t.integer :target_pace_seconds_per_km
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :planned_sessions, [:user_id, :date]
  end
end
