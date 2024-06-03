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

ActiveRecord::Schema[7.0].define(version: 2024_06_03_090057) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string "bearer_name", null: false
    t.string "api_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_key"], name: "index_api_keys_on_api_key", unique: true
  end

  create_table "free_accesses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.string "reason", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_free_accesses_on_user_id"
  end

  create_table "ips", force: :cascade do |t|
    t.inet "ip", null: false
    t.bigint "machine_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ip"], name: "index_ips_on_ip", unique: true
    t.index ["machine_id"], name: "index_ips_on_machine_id"
  end

  create_table "machines", force: :cascade do |t|
    t.string "name", null: false
    t.macaddr "mac", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["mac"], name: "index_machines_on_mac", unique: true
    t.index ["user_id"], name: "index_machines_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.datetime "start_at", precision: nil, null: false
    t.datetime "end_at", precision: nil, null: false
    t.virtual "duration", type: :integer, comment: "Duration in months", as: "((EXTRACT(year FROM age(end_at, start_at)) * (12)::numeric) + EXTRACT(month FROM age(end_at, start_at)))", stored: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.string "email", null: false
    t.string "room", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "keycloak_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["keycloak_id"], name: "index_users_on_keycloak_id", unique: true
    t.index ["room"], name: "index_users_on_room", unique: true
  end

  add_foreign_key "free_accesses", "users"
  add_foreign_key "ips", "machines"
  add_foreign_key "machines", "users"
  add_foreign_key "subscriptions", "users"
end
