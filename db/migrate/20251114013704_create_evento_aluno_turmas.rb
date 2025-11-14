class CreateEventoAlunoTurmas < ActiveRecord::Migration[7.0]
  def change
    create_table :evento_aluno_turmas do |t|
      t.integer :evento_id, null: false
      t.integer :turma_id, null: false
      t.integer :aluno_id, null: false

      t.timestamps
    end

    add_index :evento_aluno_turmas, [:evento_id, :turma_id, :aluno_id], unique: true, name: 'index_evento_turma_aluno'
  end
end