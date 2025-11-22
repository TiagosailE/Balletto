class AddValorToEventos < ActiveRecord::Migration[8.0]
  def change
    add_column :eventos, :EVE_VALOR, :decimal, precision: 10, scale: 2, default: 0.0
  end
end