# frozen_string_literal: true

class CreateTrainingPhases < ActiveRecord::Migration[8.1]
  def change
    create_table :training_phases do |t|
      t.references :user, null: false, foreign_key: true
      t.references :competition, foreign_key: true
      t.string :name, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.integer :phase_type, null: false, default: 0
      t.string :color, null: false, default: "#6366f1"
      t.text :description

      t.timestamps
    end

    add_index :training_phases, [:user_id, :start_date, :end_date]
  end
end
