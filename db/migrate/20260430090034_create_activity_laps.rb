# frozen_string_literal: true

class CreateActivityLaps < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_laps do |t|
      t.references :activity, null: false, foreign_key: true
      t.integer :lap_number, null: false
      t.integer :distance_meters
      t.integer :duration_seconds
      t.integer :average_heart_rate
      t.integer :average_pace_seconds_per_km
      t.integer :elevation_gain_meters

      t.timestamps
    end
  end
end
