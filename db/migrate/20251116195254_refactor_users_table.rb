class RefactorUsersTable < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:users, :role)
      remove_column :users, :role, :integer
    end

    rename_column :users, :nome, :usu_nome
    rename_column :users, :usuario, :usu_login
    rename_column :users, :telefone, :usu_telefone
    rename_column :users, :data_cont, :usu_data_contratacao
    rename_column :users, :status, :usu_status
    rename_column :users, :especialidades, :usu_especialidades
  end
end
