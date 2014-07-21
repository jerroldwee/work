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

ActiveRecord::Schema.define(version: 20140703084934) do

  create_table "attachments", force: true do |t|
    t.string   "guid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
  end

  add_index "attachments", ["guid"], name: "index_attachments_on_guid", using: :btree

  create_table "billing_addresses", force: true do |t|
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "address_line_3"
    t.string   "region"
    t.string   "state"
    t.string   "postal_code"
    t.string   "contact_no"
    t.string   "full_name"
    t.integer  "user_id"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  add_index "billing_addresses", ["user_id"], name: "index_billing_addresses_on_user_id", using: :btree

  create_table "billings", force: true do |t|
    t.string   "address_line_1"
    t.string   "address_line2"
    t.string   "address_line_3"
    t.string   "region"
    t.string   "state"
    t.string   "postal_code"
    t.string   "billing_contact_no"
    t.string   "billing_name"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address_line_2"
  end

  create_table "carts", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "choices", force: true do |t|
    t.integer  "product_id"
    t.integer  "color_id"
    t.integer  "inventory_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "colors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_rewards", force: true do |t|
    t.integer  "user_id"
    t.string   "description"
    t.integer  "total"
    t.string   "reward_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "credit_rewards", ["user_id"], name: "index_credit_rewards_on_user_id", using: :btree

  create_table "fit_room_images", force: true do |t|
    t.integer  "product_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
    t.string   "name"
    t.integer  "color_id"
  end

  create_table "frame_shapes", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "frame_widths", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitation_records", force: true do |t|
    t.string   "from_uid"
    t.string   "to_uid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitation_records", ["from_uid"], name: "index_invitation_records_on_from_uid", using: :btree
  add_index "invitation_records", ["to_uid"], name: "index_invitation_records_on_to_uid", using: :btree

  create_table "lens", force: true do |t|
    t.string   "name"
    t.float    "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lens", ["price"], name: "index_lens_on_price", using: :btree

  create_table "line_items", force: true do |t|
    t.integer  "product_id"
    t.integer  "cart_id"
    t.integer  "order_id"
    t.integer  "quantity"
    t.decimal  "price",           precision: 10, scale: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "color_id"
    t.integer  "lens_id"
    t.float    "amount"
    t.text     "info"
    t.string   "attachment_guid"
  end

  add_index "line_items", ["attachment_guid"], name: "index_line_items_on_attachment_guid", using: :btree
  add_index "line_items", ["cart_id"], name: "index_line_items_on_cart_id", using: :btree
  add_index "line_items", ["order_id"], name: "index_line_items_on_order_id", using: :btree
  add_index "line_items", ["product_id"], name: "index_line_items_on_product_id", using: :btree

  create_table "materials", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "model_images", force: true do |t|
    t.string   "type"
    t.integer  "product_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
  end

  create_table "orders", force: true do |t|
    t.string   "no"
    t.integer  "billing_id"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "address_line_3"
    t.string   "email"
    t.string   "payment_type"
    t.boolean  "paid"
    t.string   "payment_receipt"
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name"
    t.string   "state"
    t.string   "region"
    t.string   "country"
    t.string   "contact_no"
    t.string   "postal_code"
    t.string   "delivery_type"
    t.string   "checkout_token"
    t.string   "paypal_checkout_token"
    t.string   "paypal_email"
    t.string   "paypal_customer_token"
    t.string   "paypal_payment_transaction_id"
    t.integer  "user_id"
    t.integer  "discount_credit"
    t.string   "order_number"
    t.string   "order_status"
    t.text     "admin_remark"
    t.text     "user_remark"
    t.string   "delivery_tracking_url"
  end

  add_index "orders", ["checkout_token"], name: "index_orders_on_checkout_token", using: :btree
  add_index "orders", ["paypal_checkout_token"], name: "index_orders_on_paypal_checkout_token", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "prescriptions", force: true do |t|
    t.integer  "user_id"
    t.text     "info"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_images", force: true do |t|
    t.integer  "choice_id"
    t.integer  "product_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.decimal  "price",          precision: 10, scale: 0
    t.string   "code"
    t.string   "product_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gender"
    t.integer  "material_id"
    t.integer  "frame_shape_id"
    t.integer  "frame_width_id"
    t.string   "brand"
  end

  add_index "products", ["frame_shape_id"], name: "index_products_on_frame_shape_id", using: :btree
  add_index "products", ["frame_width_id"], name: "index_products_on_frame_width_id", using: :btree
  add_index "products", ["gender"], name: "index_products_on_gender", using: :btree
  add_index "products", ["material_id"], name: "index_products_on_material_id", using: :btree

  create_table "promotions", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_updated_at"
  end

  create_table "user_fit_rooms", force: true do |t|
    t.float    "left"
    t.float    "top"
    t.float    "width"
    t.float    "height"
    t.float    "rotation"
    t.boolean  "temprary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "target_image_file_name"
    t.string   "target_image_content_type"
    t.integer  "target_image_file_size"
    t.datetime "target_image_updated_at"
    t.integer  "user_id"
    t.integer  "product_id"
    t.integer  "color_id"
    t.string   "facebook_post_id"
    t.boolean  "sample_man",                default: false
    t.string   "title"
  end

  add_index "user_fit_rooms", ["facebook_post_id"], name: "index_user_fit_rooms_on_facebook_post_id", using: :btree
  add_index "user_fit_rooms", ["user_id"], name: "index_user_fit_rooms_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "full_name"
    t.string   "contact_no"
    t.string   "api_key"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_as"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "token"
    t.integer  "total_credit",           default: 0
    t.string   "nric"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["nric"], name: "index_users_on_nric", using: :btree
  add_index "users", ["token"], name: "index_users_on_token", using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end
