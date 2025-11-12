class CreateAlunoXEventos < ActiveRecord::Migration[8.0]
  def change
    create_table :aluno_x_eventos do |t|
      t.integer :ALU_CODIGO
      t.integer :EVE_CODIGO
      t.boolean :PRESENCA

      t.timestamps
    end
  end
end
