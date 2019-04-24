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

ActiveRecord::Schema.define(version: 2019_04_23_114857) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "page_images", id: :serial, force: :cascade do |t|
    t.jsonb "image"
    t.integer "volume"
    t.integer "page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "searches", id: :serial, force: :cascade do |t|
    t.integer "tr_paragraph_id"
    t.integer "transcription_xml_id"
    t.string "entry"
    t.string "lang"
    t.integer "volume"
    t.integer "page"
    t.integer "paragraph"
    t.text "content"
    t.date "date"
    t.string "date_incorrect"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "date_certainty", default: "high"
    t.date "date_not_after"
    t.index ["page"], name: "index_searches_on_page"
    t.index ["paragraph"], name: "index_searches_on_paragraph"
    t.index ["volume"], name: "index_searches_on_volume"
  end

  create_table "tr_paragraphs", id: :serial, force: :cascade do |t|
    t.text "content_xml"
    t.text "content_html"
    t.integer "search_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transcription_xmls", id: :serial, force: :cascade do |t|
    t.jsonb "xml"
    t.string "filename"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["filename"], name: "index_transcription_xmls_on_filename", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "searches", "tr_paragraphs", on_delete: :cascade
  add_foreign_key "searches", "transcription_xmls"
  add_foreign_key "tr_paragraphs", "searches", on_delete: :cascade
end
