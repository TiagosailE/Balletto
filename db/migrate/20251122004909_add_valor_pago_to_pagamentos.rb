class AddValorPagoToPagamentos < ActiveRecord::Migration[8.0]
  def change
    add_column :pagamentos, :pag_valor_pago, :decimal, precision: 10, scale: 2, default: 0.0
  end
end