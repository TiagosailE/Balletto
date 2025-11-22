class AddColumnasToConfiguracoes < ActiveRecord::Migration[8.0]
  def change
    add_column :configuracoes, :chave, :string, null: false
    add_column :configuracoes, :valor, :text
    
    add_index :configuracoes, :chave, unique: true
  end
end