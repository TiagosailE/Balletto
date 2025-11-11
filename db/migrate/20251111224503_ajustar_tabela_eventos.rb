class AjustarTabelaEventos < ActiveRecord::Migration[7.1]
  def change
    # Remove a PK padrão
    remove_column :eventos, :id, :integer if column_exists?(:eventos, :id)

    # Adiciona a nova PK personalizada
    add_column :eventos, :EVE_CODIGO, :primary_key
    change_column :eventos, :EVE_NOME, :string, limit: 100
    change_column :eventos, :EVE_LOCAL, :string, limit: 150
    change_column :eventos, :EVE_DESC, :string, limit: 255
  end
end
