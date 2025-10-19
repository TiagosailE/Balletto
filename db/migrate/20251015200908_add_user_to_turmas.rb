class AddUserToTurmas < ActiveRecord::Migration[8.0]
  def change
    add_reference :turmas, :user, null: true, foreign_key: true
  end
end
