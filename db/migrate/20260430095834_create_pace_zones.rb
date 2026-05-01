# frozen_string_literal: true

class CreatePaceZones < ActiveRecord::Migration[8.1]
  def change
    create_table :pace_zones do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :zone_number, null: false
      t.string :name, null: false
      t.integer :min_pace_seconds_per_km, null: false
      t.integer :max_pace_seconds_per_km, null: false
      t.string :color

      t.timestamps
    end

    add_index :pace_zones, [:user_id, :zone_number], unique: true
  end
end
