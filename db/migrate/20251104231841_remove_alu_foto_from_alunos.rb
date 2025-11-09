class RemoveAluFotoFromAlunos < ActiveRecord::Migration[8.0]
  def change
    # Verifica se a coluna antiga 'alu_foto' existe antes de tentar removê-la
    if column_exists?(:alunos, :alu_foto)
      remove_column :alunos, :alu_foto, :string
    end
  end
end
