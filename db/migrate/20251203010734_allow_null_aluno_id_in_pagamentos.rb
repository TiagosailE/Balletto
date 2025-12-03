class AllowNullAlunoIdInPagamentos < ActiveRecord::Migration[8.0]
  def change
    change_column_null :pagamentos, :aluno_id, true
  end
end