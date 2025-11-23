class CreatePossivelAlunos < ActiveRecord::Migration[8.0]
  def change
    create_table :possivel_alunos do |t|
      t.string :pos_nome
      t.string :pos_telefone
      t.string :pos_email
      t.text :pos_observacao

      t.timestamps
    end
  end
end
