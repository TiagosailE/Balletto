class AddFieldsToAlunos < ActiveRecord::Migration[8.0]
  def change
    # Colunas que faltam no modelo de Aluno dele
    add_column :alunos, :alu_data_nascimento, :date
    add_column :alunos, :alu_responsavel, :string
    add_column :alunos, :alu_status, :string, default: 'matriculado'
    add_column :alunos, :alu_data_cadastro, :date
    add_column :alunos, :alu_endereco, :text
    add_column :alunos, :alu_foto, :string # Para o caminho da foto

    # Coluna para saber qual usuário (professor/admin) cadastrou o aluno
    add_reference :alunos, :user, foreign_key: true, null: true
  end
end