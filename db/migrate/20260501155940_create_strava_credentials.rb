# frozen_string_literal: true

class CreateStravaCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :strava_credentials do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.bigint :strava_athlete_id, null: false
      t.string :access_token, null: false
      t.string :refresh_token, null: false
      t.datetime :expires_at, null: false
      t.datetime :last_sync_at

      t.timestamps
    end
  end
end
