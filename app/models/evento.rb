class Evento < ApplicationRecord
  self.table_name = 'eventos'
  self.primary_key = 'EVE_CODIGO'

  has_many :turma_x_eventos, foreign_key: 'EVE_CODIGO', primary_key: 'EVE_CODIGO', dependent: :destroy
  has_many :turmas, through: :turma_x_eventos, source: :turma
  
  # Relação com participantes confirmados
  has_many :evento_aluno_turmas, foreign_key: 'evento_id', primary_key: 'EVE_CODIGO', dependent: :destroy
  has_many :participantes_confirmados, through: :evento_aluno_turmas, source: :aluno
  
  # Relação com pagamentos
  has_many :pagamentos, foreign_key: 'evento_id', primary_key: 'EVE_CODIGO', dependent: :destroy

  accepts_nested_attributes_for :turma_x_eventos, allow_destroy: true

  validates :EVE_NOME, presence: true, length: { maximum: 100 }
  validates :EVE_LOCAL, presence: true, length: { maximum: 150 }
  validates :EVE_DATA, presence: true
  validates :EVE_VALOR, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  # Verifica quantos alunos já pagaram
  def total_pagos
    pagamentos.where(pag_status: 'Pago').count
  end
  
  # Verifica quantos alunos ainda não pagaram
  def total_pendentes
    participantes_confirmados.distinct.count - total_pagos
  end
end