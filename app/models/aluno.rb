class Aluno < ApplicationRecord
  self.table_name  = 'alunos'
  self.primary_key = 'alu_codigo'

  belongs_to :user
  belongs_to :turma, foreign_key: 'alu_tur_codigo', primary_key: 'tur_codigo', optional: true

  has_many :pagamentos,
           foreign_key: 'aluno_id',
           primary_key: 'alu_codigo',
           dependent: false

  has_many :aluno_x_eventos,
           foreign_key: 'ALU_CODIGO',
           primary_key: 'alu_codigo',
           dependent: :destroy

  has_one_attached :foto

  validates :alu_nome, presence: true, length: { maximum: 100 }
end
