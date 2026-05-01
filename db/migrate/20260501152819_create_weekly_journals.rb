# frozen_string_literal: true

class CreateWeeklyJournals < ActiveRecord::Migration[8.1]
  def change
    create_table :weekly_journals do |t|
      t.references :user, null: false, foreign_key: true
      t.date :week_start_date, null: false
      t.integer :pleasure
      t.integer :difficulty
      t.integer :fatigue
      t.text :comment

      t.timestamps
    end

    add_index :weekly_journals, [:user_id, :week_start_date], unique: true
  end
end
