class ChangeEveDescToBeTextInEventos < ActiveRecord::Migration[7.1]
  def change
    change_column :eventos, :EVE_DESC, :text
  end
end
