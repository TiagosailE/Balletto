class RemoveProfessorFromTurmas < ActiveRecord::Migration[8.0]
  def change
    remove_column :turmas, :professor, :string
  end
end
