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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160522052328) do

  create_table "follows", force: :cascade do |t|
    t.integer "user_id",   limit: 4, null: false
    t.integer "friend_id", limit: 4, null: false
  end

  add_index "follows", ["friend_id"], name: "fk_rails_9c4f187590", using: :btree
  add_index "follows", ["user_id", "friend_id"], name: "index_follows_on_user_id_and_friend_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",        limit: 15, null: false
    t.datetime "last_update",            null: false
  end

  add_index "users", ["last_update"], name: "index_users_on_last_update", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree

  add_foreign_key "follows", "users"
  add_foreign_key "follows", "users", column: "friend_id"
end
