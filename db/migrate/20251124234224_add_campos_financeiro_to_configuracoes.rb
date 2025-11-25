class AddCamposFinanceiroToConfiguracoes < ActiveRecord::Migration[7.0]
  def change
    add_column :configuracoes, :con_nome_academia, :string
    add_column :configuracoes, :con_valor_mensalidade, :decimal, precision: 10, scale: 2, default: 120.00
    add_column :configuracoes, :dia_vencimento_mensalidade, :integer, default: 10
  end
end
