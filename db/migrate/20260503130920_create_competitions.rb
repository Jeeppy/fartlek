# frozen_string_literal: true

class CreateCompetitions < ActiveRecord::Migration[8.1]
  def change
    create_table :competitions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.date :date, null: false
      t.integer :priority, null: false, default: 0
      t.integer :sport, null: false, default: 0
      t.integer :target_distance_meters
      t.integer :target_time_seconds
      t.integer :target_pace_seconds_per_km
      t.string :location
      t.text :objectives
      t.text :notes
      t.integer :result_time_seconds
      t.integer :result_pace_seconds_per_km
      t.integer :result_position
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :competitions, [:user_id, :date]
  end
end
