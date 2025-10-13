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

ActiveRecord::Schema[8.0].define(version: 2025_10_13_230403) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "alunos", primary_key: "alu_codigo", force: :cascade do |t|
    t.string "alu_nome", limit: 100, null: false
    t.integer "alu_tur_codigo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "possiveis_alunos", primary_key: "pos_codigo", force: :cascade do |t|
    t.string "pos_nome", limit: 100, null: false
    t.datetime "pos_data_contato"
    t.string "pos_telefone", limit: 20
    t.string "pos_email", limit: 100
    t.string "pos_status", limit: 1, default: "P"
    t.text "pos_observacao"
    t.datetime "pos_data_cad"
    t.string "avatar_url", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pos_email"], name: "index_possiveis_alunos_on_pos_email"
    t.index ["pos_nome"], name: "index_possiveis_alunos_on_pos_nome"
  end

  create_table "turmas", primary_key: "tur_codigo", force: :cascade do |t|
    t.string "tur_nome", limit: 50, null: false
    t.datetime "tur_horario"
    t.string "tur_nivel", limit: 25
    t.integer "tur_capacidade", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tur_dia_da_semana"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alunos", "turmas", column: "alu_tur_codigo", primary_key: "tur_codigo"
end
