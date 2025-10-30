class FixForeignKeyOnTurmas < ActiveRecord::Migration[7.0]
  def change
    # Remove a foreign key antiga
    remove_foreign_key :turmas, :users

    # Cria novamente permitindo que, ao excluir um usuário, o campo user_id fique nulo
    add_foreign_key :turmas, :users, column: :user_id, on_delete: :nullify
  end
end
