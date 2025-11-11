class CreateTurmaXEventos < ActiveRecord::Migration[8.0]
  def change
    create_table :turma_x_eventos do |t|
      t.integer :TUR_CODIGO
      t.integer :EVE_CODIGO

      t.timestamps
    end
  end
end
