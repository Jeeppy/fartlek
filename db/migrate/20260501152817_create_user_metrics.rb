# frozen_string_literal: true

class CreateUserMetrics < ActiveRecord::Migration[8.1]
  def change
    create_table :user_metrics do |t|
      t.references :user, null: false, foreign_key: true
      t.date :recorded_on, null: false
      t.integer :metric_type, null: false
      t.decimal :value, precision: 8, scale: 2, null: false
      t.string :unit, null: false
      t.text :notes

      t.timestamps
    end

    add_index :user_metrics, [:user_id, :metric_type, :recorded_on]
  end
end
