class CondicaoMedica < ApplicationRecord
  self.primary_key = 'con_codigo'

  has_many :condicao_alunos, foreign_key: 'con_codigo'
  has_many :alunos, through: :condicao_alunos
end