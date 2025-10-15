class AddUserToTurmas < ActiveRecord::Migration[7.1]
  def change
    add_reference :turmas, :user, null: true, foreign_key: true
  end
end
