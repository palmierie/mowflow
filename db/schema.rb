# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180108000514) do

  create_table "businesses", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "signed_in"
    t.index ["user_id"], name: "index_businesses_on_user_id"
  end

  create_table "clients", force: :cascade do |t|
    t.integer "business_id"
    t.string "full_name"
    t.string "second_full_name"
    t.string "email"
    t.string "second_email"
    t.string "phone"
    t.string "second_phone"
    t.text "additional_note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_clients_on_business_id"
  end

  create_table "durations", force: :cascade do |t|
    t.integer "duration"
    t.text "duration_desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "extra_durations", force: :cascade do |t|
    t.integer "duration"
    t.text "duration_desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keys", force: :cascade do |t|
    t.string "name"
    t.text "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "schedule_histories", force: :cascade do |t|
    t.integer "business_id"
    t.datetime "date"
    t.text "mow_list"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_schedule_histories_on_business_id"
  end

  create_table "scheduled_locations", force: :cascade do |t|
    t.integer "client_id"
    t.integer "business_id"
    t.boolean "depot"
    t.text "location_desc"
    t.string "street_address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "google_place_id"
    t.string "coordinates"
    t.date "start_season"
    t.date "end_season"
    t.string "day_of_week"
    t.integer "mow_frequency"
    t.date "date_mowed"
    t.date "next_mow_date"
    t.date "service_date"
    t.boolean "in_progress"
    t.integer "duration_id"
    t.integer "extra_duration_id"
    t.text "user_notes"
    t.text "special_job_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["business_id"], name: "index_scheduled_locations_on_business_id"
    t.index ["client_id"], name: "index_scheduled_locations_on_client_id"
    t.index ["duration_id"], name: "index_scheduled_locations_on_duration_id"
    t.index ["extra_duration_id"], name: "index_scheduled_locations_on_extra_duration_id"
  end

  create_table "user_businesses", force: :cascade do |t|
    t.integer "user_id"
    t.integer "business_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_user_businesses_on_business_id"
    t.index ["user_id"], name: "index_user_businesses_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.string "first_name"
    t.string "last_name"
    t.integer "business_id"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_users_on_business_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
