class CreateAlunos < ActiveRecord::Migration[7.0]
  def change
    create_table :alunos, id: false do |t|
      t.primary_key :alu_codigo
      t.string :alu_nome, limit: 100, null: false
      t.integer :alu_tur_codigo, null: true
      t.foreign_key :turmas, column: :alu_tur_codigo, primary_key: :tur_codigo
      t.timestamps
    end
  end
end