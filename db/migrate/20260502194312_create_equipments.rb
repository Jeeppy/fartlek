# frozen_string_literal: true

class CreateEquipments < ActiveRecord::Migration[8.1]
  def change
    create_table :equipment do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :equipment_type, null: false, default: 0
      t.string :brand
      t.string :model
      t.date :purchase_date
      t.integer :initial_distance_meters, default: 0
      t.integer :max_distance_meters
      t.boolean :retired, null: false, default: false
      t.text :notes

      t.timestamps
    end

    add_reference :activities, :equipment, foreign_key: true
  end
end
