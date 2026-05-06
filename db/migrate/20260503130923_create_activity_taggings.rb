# frozen_string_literal: true

class CreateActivityTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_taggings do |t|
      t.references :activity, null: false, foreign_key: true
      t.references :activity_tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :activity_taggings, [:activity_id, :activity_tag_id], unique: true
  end
end
