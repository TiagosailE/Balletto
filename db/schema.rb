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

ActiveRecord::Schema[7.1].define(version: 2025_10_15_200908) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alunos", primary_key: "alu_codigo", force: :cascade do |t|
    t.string "alu_nome", limit: 100, null: false
    t.integer "alu_tur_codigo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "alu_data_nascimento"
    t.string "alu_responsavel"
    t.string "alu_status", default: "matriculado"
    t.date "alu_data_cadastro"
    t.text "alu_endereco"
    t.string "alu_foto"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_alunos_on_user_id"
  end

  create_table "turmas", primary_key: "tur_codigo", force: :cascade do |t|
    t.string "tur_nome", limit: 50, null: false
    t.datetime "tur_horario"
    t.string "tur_nivel", limit: 25
    t.integer "tur_capacidade", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tur_dia_da_semana", limit: 20
    t.bigint "user_id"
    t.index ["user_id"], name: "index_turmas_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "nome", default: "", null: false
    t.string "usuario", default: "", null: false
    t.integer "role", default: 0
    t.string "telefone"
    t.date "data_cont"
    t.string "status", default: "ativo"
    t.text "especialidades"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["usuario"], name: "index_users_on_usuario", unique: true
  end

  add_foreign_key "alunos", "turmas", column: "alu_tur_codigo", primary_key: "tur_codigo"
  add_foreign_key "alunos", "users"
  add_foreign_key "turmas", "users"
end
