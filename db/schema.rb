# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_30_090034) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer "average_heart_rate"
    t.integer "average_pace_seconds_per_km"
    t.integer "calories"
    t.datetime "created_at", null: false
    t.integer "distance_meters"
    t.integer "duration_seconds"
    t.integer "elevation_gain_meters"
    t.integer "feeling"
    t.integer "max_heart_rate"
    t.text "notes"
    t.datetime "performed_at", null: false
    t.integer "rpe"
    t.integer "sport", null: false
    t.jsonb "strava_data"
    t.bigint "strava_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["strava_id"], name: "index_activities_on_strava_id", unique: true
    t.index ["user_id", "performed_at"], name: "index_activities_on_user_id_and_performed_at"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "activity_laps", force: :cascade do |t|
    t.bigint "activity_id", null: false
    t.integer "average_heart_rate"
    t.integer "average_pace_seconds_per_km"
    t.datetime "created_at", null: false
    t.integer "distance_meters"
    t.integer "duration_seconds"
    t.integer "elevation_gain_meters"
    t.integer "lap_number", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_activity_laps_on_activity_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.date "date_of_birth", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.integer "gender", null: false
    t.string "last_name", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "time_zone", default: "Europe/Paris", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "users"
  add_foreign_key "activity_laps", "activities"
end
