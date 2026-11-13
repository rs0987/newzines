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

ActiveRecord::Schema[8.1].define(version: 2026_11_13_110321) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "username", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_accounts_on_username", unique: true
  end

  create_table "administrators", force: :cascade do |t|
    t.string "username", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["username"], name: "index_administrators_on_username", unique: true
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "studio_id", null: false
    t.bigint "inviter_id", null: false
    t.string "username", null: false
    t.string "token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "accepted_at"
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
    t.index ["studio_id"], name: "index_invitations_on_studio_id"
    t.index ["token_digest"], name: "index_invitations_on_token_digest", unique: true
    t.index ["username"], name: "index_invitations_on_username"
  end

  create_table "studio_memberships", force: :cascade do |t|
    t.bigint "studio_id", null: false
    t.bigint "writer_id", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["studio_id", "writer_id"], name: "index_studio_memberships_on_studio_id_and_writer_id", unique: true
    t.index ["writer_id"], name: "index_studio_memberships_on_writer_id"
  end

  create_table "studios", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_studios_on_slug", unique: true
  end

  create_table "writers", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_writers_on_account_id", unique: true
  end

  add_foreign_key "invitations", "administrators", column: "inviter_id"
  add_foreign_key "invitations", "studios"
  add_foreign_key "studio_memberships", "studios"
  add_foreign_key "studio_memberships", "writers"
  add_foreign_key "writers", "accounts"
end
