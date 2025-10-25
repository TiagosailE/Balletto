class Responsavel < ApplicationRecord
    self.table_name = 'responsaveis'
    self.primary_key = 'res_codigo'

    has_many :alunos, foreign_key: 'res_codigo'
end
