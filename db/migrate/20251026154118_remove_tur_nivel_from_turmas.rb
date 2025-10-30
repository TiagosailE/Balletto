class RemoveTurNivelFromTurmas < ActiveRecord::Migration[8.0]
  def change
    remove_column :turmas, :tur_nivel, :string
  end
end
