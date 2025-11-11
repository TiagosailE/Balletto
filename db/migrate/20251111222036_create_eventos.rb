class CreateEventos < ActiveRecord::Migration[8.0]
  def change
    create_table :eventos do |t|
      t.string :EVE_NOME
      t.datetime :EVE_DATA
      t.string :EVE_LOCAL
      t.string :EVE_DESC

      t.timestamps
    end
  end
end
