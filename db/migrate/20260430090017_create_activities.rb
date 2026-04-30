# frozen_string_literal: true

class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :sport, null: false
      t.string :title
      t.datetime :performed_at, null: false
      t.integer :duration_seconds
      t.integer :distance_meters
      t.integer :elevation_gain_meters
      t.integer :average_heart_rate
      t.integer :max_heart_rate
      t.integer :average_pace_seconds_per_km
      t.integer :calories
      t.integer :rpe
      t.integer :feeling
      t.text :notes
      t.bigint :strava_id
      t.jsonb :strava_data

      t.timestamps
    end

    add_index :activities, [:user_id, :performed_at]
    add_index :activities, :strava_id, unique: true
  end
end
