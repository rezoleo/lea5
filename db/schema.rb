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

ActiveRecord::Schema[7.2].define(version: 2025_12_14_175208) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "name", null: false
    t.string "api_key_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["api_key_digest"], name: "index_api_keys_on_api_key_digest", unique: true
  end

  create_table "articles", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price_cents", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "articles_refunds", primary_key: ["article_id", "refund_id"], force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "refund_id", null: false
    t.integer "quantity", null: false
    t.index ["article_id"], name: "index_articles_refunds_on_article_id"
    t.index ["refund_id"], name: "index_articles_refunds_on_refund_id"
  end

  create_table "articles_sales", primary_key: ["article_id", "sale_id"], force: :cascade do |t|
    t.bigint "article_id", null: false
    t.bigint "sale_id", null: false
    t.integer "quantity", null: false
    t.index ["article_id"], name: "index_articles_sales_on_article_id"
    t.index ["sale_id"], name: "index_articles_sales_on_sale_id"
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

  create_table "invoices", force: :cascade do |t|
    t.bigint "number", default: 0, null: false
    t.jsonb "generation_json", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_invoices_on_number", unique: true
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

  create_table "payment_methods", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "auto_verify", default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "refunds", force: :cascade do |t|
    t.bigint "refunder_id"
    t.bigint "refund_method_id", null: false
    t.bigint "sale_id", null: false
    t.bigint "invoice_id", null: false
    t.string "reason"
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_refunds_on_invoice_id"
    t.index ["refund_method_id"], name: "index_refunds_on_refund_method_id"
    t.index ["refunder_id"], name: "index_refunds_on_refunder_id"
    t.index ["sale_id"], name: "index_refunds_on_sale_id"
  end

  create_table "refunds_subscription_offers", primary_key: ["refund_id", "subscription_offer_id"], force: :cascade do |t|
    t.bigint "refund_id", null: false
    t.bigint "subscription_offer_id", null: false
    t.integer "quantity", null: false
    t.index ["refund_id"], name: "index_refunds_subscription_offers_on_refund_id"
    t.index ["subscription_offer_id"], name: "index_refunds_subscription_offers_on_subscription_offer_id"
  end

  create_table "sales", force: :cascade do |t|
    t.bigint "seller_id"
    t.bigint "client_id", null: false
    t.bigint "payment_method_id", null: false
    t.bigint "invoice_id", null: false
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_sales_on_client_id"
    t.index ["invoice_id"], name: "index_sales_on_invoice_id"
    t.index ["payment_method_id"], name: "index_sales_on_payment_method_id"
    t.index ["seller_id"], name: "index_sales_on_seller_id"
  end

  create_table "sales_subscription_offers", primary_key: ["sale_id", "subscription_offer_id"], force: :cascade do |t|
    t.bigint "sale_id", null: false
    t.bigint "subscription_offer_id", null: false
    t.integer "quantity", null: false
    t.index ["sale_id"], name: "index_sales_subscription_offers_on_sale_id"
    t.index ["subscription_offer_id"], name: "index_sales_subscription_offers_on_subscription_offer_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "key", null: false
    t.string "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "subscription_offers", force: :cascade do |t|
    t.integer "duration", null: false
    t.integer "price_cents", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_at", null: false
    t.datetime "end_at", null: false
    t.virtual "duration", type: :integer, comment: "Duration in months", as: "((EXTRACT(year FROM age(date_trunc('months'::text, end_at), date_trunc('months'::text, start_at))) * (12)::numeric) + EXTRACT(month FROM age(date_trunc('months'::text, end_at), date_trunc('months'::text, start_at))))", stored: true
    t.bigint "sale_id", null: false
    t.index ["sale_id"], name: "index_subscriptions_on_sale_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.string "email", null: false
    t.string "room"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "oidc_id"
    t.string "wifi_password", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["oidc_id"], name: "index_users_on_oidc_id", unique: true
    t.index ["room"], name: "index_users_on_room", unique: true, where: "(room IS NOT NULL)"
    t.index ["username"], name: "index_users_on_username", unique: true
    t.index ["wifi_password"], name: "index_users_on_wifi_password"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "articles_refunds", "articles"
  add_foreign_key "articles_refunds", "refunds"
  add_foreign_key "articles_sales", "articles"
  add_foreign_key "articles_sales", "sales"
  add_foreign_key "free_accesses", "users"
  add_foreign_key "ips", "machines"
  add_foreign_key "machines", "users"
  add_foreign_key "refunds", "invoices"
  add_foreign_key "refunds", "payment_methods", column: "refund_method_id"
  add_foreign_key "refunds", "sales"
  add_foreign_key "refunds", "users", column: "refunder_id"
  add_foreign_key "refunds_subscription_offers", "refunds"
  add_foreign_key "refunds_subscription_offers", "subscription_offers"
  add_foreign_key "sales", "invoices"
  add_foreign_key "sales", "payment_methods"
  add_foreign_key "sales", "users", column: "client_id"
  add_foreign_key "sales", "users", column: "seller_id"
  add_foreign_key "sales_subscription_offers", "sales"
  add_foreign_key "sales_subscription_offers", "subscription_offers"
  add_foreign_key "subscriptions", "sales"
end
