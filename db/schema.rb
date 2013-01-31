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

ActiveRecord::Schema.define(:version => 20121227130326) do

  create_table "log_action_parameters", :force => true do |t|
    t.integer  "peer_log_id"
    t.integer  "param_object_type_id"
    t.integer  "param_object_id"
    t.integer  "param_object_site_id"
    t.string   "parameter"
    t.string   "value"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "peer_logs", :force => true do |t|
    t.integer  "user_site_id"
    t.integer  "user_site_object_id"
    t.datetime "action_taken_at_time"
    t.integer  "sync_object_action_id"
    t.integer  "sync_object_type_id"
    t.integer  "sync_object_id"
    t.integer  "sync_object_site_id"
    t.integer  "push_request_id"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "pull_events", :force => true do |t|
    t.integer  "site_id"
    t.datetime "pull_at"
    t.datetime "success_at"
    t.string   "state_uuid"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "success"
    t.string   "file_url"
    t.string   "file_md5_hash"
    t.datetime "failed_at"
    t.string   "failed_reason"
  end

  create_table "push_requests", :force => true do |t|
    t.integer  "site_id"
    t.string   "file_url"
    t.string   "file_md5_hash"
    t.datetime "received_at"
    t.datetime "success_at"
    t.datetime "failed_at"
    t.string   "failed_reason"
    t.string   "uuid"
    t.integer  "success"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "current_uuid"
    t.string   "url"
    t.string   "auth_code"
    t.string   "response_url"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "sync_object_actions", :force => true do |t|
    t.string   "object_action"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "sync_object_types", :force => true do |t|
    t.string   "object_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
