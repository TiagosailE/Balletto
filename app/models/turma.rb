class Turma < ApplicationRecord
  self.table_name = 'turmas'
  self.primary_key = 'tur_codigo'

  validates :tur_nome, presence: true, length: { maximum: 50 }
  validates :tur_capacidade, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to:255 }, allow_nil: true

  has_many :alunos, foreign_key: 'alu_tur_codigo', primary_key: 'tur_codigo', dependent: :nullify
  has_many :turma_x_eventos, foreign_key: 'TUR_CODIGO', primary_key: 'tur_codigo', dependent: :destroy
  has_many :eventos, through: :turma_x_eventos, source: :evento

  belongs_to :professor, class_name: 'User', foreign_key: 'user_id', optional: true

serialize :tur_dia_da_semana, coder: JSON

  def vagas_ocupadas
    alunos.count
  rescue
    0
  end

  def vagas_info
    cap = tur_capacidade || 0
    "#{vagas_ocupadas}/#{cap}"
  end

  before_validation :set_default_capacidade

  private

  def set_default_capacidade
    self.tur_capacidade ||= 0
  end
end