class CreatePagamentos < ActiveRecord::Migration[7.1]
  def change
    create_table :pagamentos, id: false do |t|
      t.primary_key :pag_codigo

      # --- RELAÇÕES (O CORAÇÃO DA SUA LÓGICA) ---

      # Para qual 'caixa' (conta) este pagamento foi? (Obrigatório)
      t.references :caixa, null: false, foreign_key: { to_table: :caixas, primary_key: :cai_codigo }

      # É uma mensalidade? Ligue ao Aluno. (Opcional)
      t.references :aluno, null: true, foreign_key: { to_table: :alunos, primary_key: :alu_codigo }

      # É uma taxa de evento? Ligue ao Evento. (Opcional)
      t.references :evento, null: true, foreign_key: { to_table: :eventos, primary_key: :EVE_CODIGO }

      # (Note que ignoramos o RES_CODIGO, como você sugeriu!)

      # --- DADOS DO PAGAMENTO ---
      t.datetime :pag_data, null: false
      t.decimal :pag_valor, precision: 10, scale: 2, null: false
      t.string :pag_descricao, limit: 255
      t.string :pag_metodo, limit: 50      # Ex: "Pix", "Dinheiro", "Cartão"
      t.string :pag_tipo, limit: 10, null: false       # "Entrada" ou "Saída"
      t.string :pag_status, limit: 20, null: false    # Ex: "Pendente", "Pago", "Atrasado"

      t.timestamps
    end
  end
end