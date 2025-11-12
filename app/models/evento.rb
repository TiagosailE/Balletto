class Evento < ApplicationRecord
  self.table_name = 'eventos'
  self.primary_key = 'EVE_CODIGO'

  has_many :turma_x_eventos, foreign_key: 'EVE_CODIGO', primary_key: 'EVE_CODIGO', dependent: :destroy
  has_many :turmas, through: :turma_x_eventos, source: :turma

  accepts_nested_attributes_for :turma_x_eventos, allow_destroy: true

  validates :EVE_NOME, presence: true, length: { maximum: 100 }
  validates :EVE_LOCAL, presence: true, length: { maximum: 150 }
  validates :EVE_DATA, presence: true
end
