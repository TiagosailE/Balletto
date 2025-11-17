class CreateCaixas < ActiveRecord::Migration[8.0]
  def change
    create_table :caixas, id: false do |t|
      t.primary_key :cai_codigo
      t.string :cai_nome, limit: 100, null: false
      t.string :cai_tipo, limit: 50  # Ex: "Conta Corrente", "Caixa Físico"

      # O saldo atual será a SOMA dos pagamentos,
      # mas um saldo inicial é sempre útil.
      t.decimal :cai_saldo_inicial, precision: 10, scale: 2, default: 0.0

      t.timestamps
    end
  end
end
