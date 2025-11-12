class AlunoXEvento < ApplicationRecord
  self.primary_key = 'ALU_X_EVE_CODIGO'

  belongs_to :evento, foreign_key: 'EVE_CODIGO'
  belongs_to :aluno, foreign_key: 'ALU_CODIGO'

  scope :presentes, -> { where(PRESENCA: true) }
end
