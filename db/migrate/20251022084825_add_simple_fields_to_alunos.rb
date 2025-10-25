class AddSimpleFieldsToAlunos < ActiveRecord::Migration[8.0]
  def change
    # Renomeia a coluna de texto existente para um nome mais claro
    if column_exists?(:alunos, :alu_responsavel)
      rename_column :alunos, :alu_responsavel, :responsavel_nome
    elsif !column_exists?(:alunos, :responsavel_nome)
      add_column :alunos, :responsavel_nome, :string
    end

    # Adiciona os novos campos de texto simples
    add_column :alunos, :responsavel_telefone, :string
    add_column :alunos, :responsavel_email, :string
    add_column :alunos, :condicoes_medicas, :text
  end
end
