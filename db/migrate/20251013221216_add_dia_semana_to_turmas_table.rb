class AddDiaSemanaToTurmasTable < ActiveRecord::Migration[7.0]
  def change
    unless column_exists?(:turmas, :tur_dia_da_semana)
      add_column :turmas, :tur_dia_da_semana, :string, limit: 20
    end
  end
end