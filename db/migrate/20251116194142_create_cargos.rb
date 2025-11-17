class CreateCargos < ActiveRecord::Migration[8.0]
  def change
    create_table :cargos, id: false do |t|
      t.primary_key :car_codigo
      t.string :car_nome, limit: 50, null: false
      t.timestamps
    end
    add_index :cargos, :car_nome, unique: true
  end
end
