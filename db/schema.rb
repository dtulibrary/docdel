# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130912083505) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "external_systems", :force => true do |t|
    t.string   "code",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "external_systems", ["code"], :name => "index_external_systems_on_code", :unique => true

  create_table "institutes", :force => true do |t|
    t.string   "code",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "order_requests", :force => true do |t|
    t.integer  "order_id",                  :null => false
    t.integer  "order_status_id",           :null => false
    t.integer  "external_system_id",        :null => false
    t.float    "external_copyright_charge"
    t.string   "external_currency"
    t.integer  "external_number"
    t.float    "external_service_charge"
    t.string   "external_url"
    t.string   "shelfmark"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "reason_id"
    t.string   "reason_text"
  end

  add_index "order_requests", ["external_system_id"], :name => "index_order_requests_on_external_system_id"
  add_index "order_requests", ["order_id"], :name => "index_order_requests_on_order_id"
  add_index "order_requests", ["order_status_id"], :name => "index_order_requests_on_order_status_id"
  add_index "order_requests", ["reason_id"], :name => "index_order_requests_on_reason_id"

  create_table "order_statuses", :force => true do |t|
    t.string   "code",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "order_statuses", ["code"], :name => "index_order_statuses_on_code", :unique => true

  create_table "orders", :force => true do |t|
    t.string   "email",                 :null => false
    t.string   "callback_url",          :null => false
    t.string   "atitle"
    t.string   "aufirst"
    t.string   "aulast"
    t.string   "date"
    t.datetime "delivered_at"
    t.string   "doi"
    t.string   "eissn"
    t.string   "epage"
    t.string   "isbn"
    t.string   "issn"
    t.string   "issue"
    t.string   "pages"
    t.string   "spage"
    t.string   "title"
    t.string   "volume"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "customer_order_number"
    t.integer  "institute_id"
    t.integer  "user_type_id"
  end

  add_index "orders", ["email"], :name => "index_orders_on_email"
  add_index "orders", ["institute_id"], :name => "index_orders_on_institute_id"
  add_index "orders", ["user_type_id"], :name => "index_orders_on_user_type_id"

  create_table "reasons", :force => true do |t|
    t.string   "code",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "reasons", ["code"], :name => "index_reasons_on_code", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "user_types", :force => true do |t|
    t.string   "code",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
