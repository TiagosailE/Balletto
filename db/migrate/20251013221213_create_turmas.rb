class CreateTurmas < ActiveRecord::Migration[8.0]
  def change
    create_table :turmas, id: false do |t|
      t.primary_key :tur_codigo
      t.string :tur_nome, limit: 50, null: false
      t.datetime :tur_horario
      t.string :tur_nivel, limit: 25
      t.integer :tur_capacidade, limit: 1
      t.timestamps
    end
  end
end
