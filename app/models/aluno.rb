class Aluno < ApplicationRecord
  self.table_name = 'alunos'
  self.primary_key = 'alu_codigo'

  belongs_to :turma, foreign_key: 'alu_tur_codigo', primary_key: 'tur_codigo', optional: true
  belongs_to :user, optional: true
  
  validates :alu_nome, presence: true, length: { maximum: 100 }
end