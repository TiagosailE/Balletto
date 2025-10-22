class CondicaoAluno < ApplicationRecord
  self.primary_key = 'cond_x_alu_codigo'

  belongs_to :aluno, foreign_key: 'alu_codigo'
  belongs_to :condicao_medica, foreign_key: 'con_codigo'
end