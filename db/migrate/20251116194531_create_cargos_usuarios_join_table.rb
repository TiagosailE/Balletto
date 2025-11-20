class CreateCargosUsuariosJoinTable < ActiveRecord::Migration[8.0]
  def change
    # Tabela de ligação, sem ID próprio
    create_table :cargos_usuarios, id: false do |t|
      t.references :user, null: false, foreign_key: true
      t.references :cargo, null: false, foreign_key: { to_table: :cargos, primary_key: :car_codigo }
    end

    # Garante que um usuário não possa ter o mesmo cargo duas vezes
    add_index :cargos_usuarios, [:user_id, :cargo_id], unique: true
  end
end
