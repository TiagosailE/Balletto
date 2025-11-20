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

ActiveRecord::Schema[8.0].define(version: 2025_11_17_005613) do
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

  create_table "aluno_x_eventos", force: :cascade do |t|
    t.integer "ALU_CODIGO"
    t.integer "EVE_CODIGO"
    t.boolean "PRESENCA"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "alunos", primary_key: "alu_codigo", force: :cascade do |t|
    t.string "alu_nome", limit: 100, null: false
    t.integer "alu_tur_codigo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "alu_data_nascimento"
    t.string "responsavel_nome"
    t.string "alu_status", default: "matriculado"
    t.date "alu_data_cadastro"
    t.text "alu_endereco"
    t.bigint "user_id"
    t.string "responsavel_telefone"
    t.string "responsavel_email"
    t.text "condicoes_medicas"
    t.index ["user_id"], name: "index_alunos_on_user_id"
  end

  create_table "caixas", primary_key: "cai_codigo", force: :cascade do |t|
    t.string "cai_nome", limit: 100, null: false
    t.string "cai_tipo", limit: 50
    t.decimal "cai_saldo_inicial", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cargos", primary_key: "car_codigo", force: :cascade do |t|
    t.string "car_nome", limit: 50, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_nome"], name: "index_cargos_on_car_nome", unique: true
  end

  create_table "cargos_usuarios", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "cargo_id", null: false
    t.index ["cargo_id"], name: "index_cargos_usuarios_on_cargo_id"
    t.index ["user_id", "cargo_id"], name: "index_cargos_usuarios_on_user_id_and_cargo_id", unique: true
    t.index ["user_id"], name: "index_cargos_usuarios_on_user_id"
  end

  create_table "evento_aluno_turmas", force: :cascade do |t|
    t.integer "evento_id", null: false
    t.integer "turma_id", null: false
    t.integer "aluno_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["evento_id", "turma_id", "aluno_id"], name: "index_evento_turma_aluno", unique: true
  end

  create_table "eventos", primary_key: "EVE_CODIGO", force: :cascade do |t|
    t.string "EVE_NOME", limit: 100
    t.datetime "EVE_DATA"
    t.string "EVE_LOCAL", limit: 150
    t.text "EVE_DESC"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pagamentos", primary_key: "pag_codigo", force: :cascade do |t|
    t.bigint "caixa_id", null: false
    t.bigint "aluno_id"
    t.bigint "evento_id"
    t.datetime "pag_data", null: false
    t.decimal "pag_valor", precision: 10, scale: 2, null: false
    t.string "pag_descricao", limit: 255
    t.string "pag_metodo", limit: 50
    t.string "pag_tipo", limit: 10, null: false
    t.string "pag_status", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aluno_id"], name: "index_pagamentos_on_aluno_id"
    t.index ["caixa_id"], name: "index_pagamentos_on_caixa_id"
    t.index ["evento_id"], name: "index_pagamentos_on_evento_id"
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

  create_table "professors", force: :cascade do |t|
    t.string "pro_nome"
    t.string "pro_telefone"
    t.string "pro_email"
    t.datetime "pro_data_cont"
    t.string "pro_status"
    t.string "pro_especialidade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "turma_x_eventos", force: :cascade do |t|
    t.integer "TUR_CODIGO"
    t.integer "EVE_CODIGO"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "turmas", primary_key: "tur_codigo", force: :cascade do |t|
    t.string "tur_nome", limit: 50, null: false
    t.datetime "tur_horario"
    t.integer "tur_capacidade", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tur_dia_da_semana"
    t.string "status"
    t.string "sala"
    t.integer "max_alunos", default: 20
    t.bigint "user_id"
    t.index ["user_id"], name: "index_turmas_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "usu_nome", default: "", null: false
    t.string "usu_login", default: "", null: false
    t.string "usu_telefone"
    t.date "usu_data_contratacao"
    t.string "usu_status", default: "ativo"
    t.text "usu_especialidades"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["usu_login"], name: "index_users_on_usu_login", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alunos", "turmas", column: "alu_tur_codigo", primary_key: "tur_codigo"
  add_foreign_key "alunos", "users"
  add_foreign_key "cargos_usuarios", "cargos", primary_key: "car_codigo"
  add_foreign_key "cargos_usuarios", "users"
  add_foreign_key "pagamentos", "alunos", primary_key: "alu_codigo"
  add_foreign_key "pagamentos", "caixas", primary_key: "cai_codigo"
  add_foreign_key "pagamentos", "eventos", primary_key: "EVE_CODIGO"
  add_foreign_key "turmas", "users", on_delete: :nullify
end
