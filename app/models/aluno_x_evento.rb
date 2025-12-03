class AlunoXEvento < ApplicationRecord
  self.table_name  = "aluno_x_eventos"
  self.primary_key = "ALU_X_EVE_CODIGO"

  belongs_to :aluno,
             foreign_key: "ALU_CODIGO",
             primary_key: "alu_codigo",
             inverse_of: :aluno_x_eventos

  belongs_to :evento,
             foreign_key: "EVE_CODIGO",
             primary_key: "EVE_CODIGO",
             optional: true,
             inverse_of: :aluno_x_eventos

  scope :presentes, -> { where(PRESENCA: true) }
end
