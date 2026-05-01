# frozen_string_literal: true

class CreateHeartRateZones < ActiveRecord::Migration[8.1]
  def change
    create_table :heart_rate_zones do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :zone_number, null: false
      t.string :name, null: false
      t.integer :min_bpm, null: false
      t.integer :max_bpm, null: false
      t.string :color

      t.timestamps
    end

    add_index :heart_rate_zones, [:user_id, :zone_number], unique: true
  end
end
