class Turma < ApplicationRecord
  self.table_name = 'turmas'
  self.primary_key = 'tur_codigo'

  validates :tur_nome, presence: { message: "não pode ficar em branco" }, length: { maximum: 50 }
  validates :tur_capacidade, presence: { message: "não pode ficar em branco" },
                             numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 255, message: "deve ser maior que 0 e menor ou igual a 255" }
  validates :tur_horario, presence: { message: "não pode ficar em branco" }
  
  validate :verificar_dias_da_semana

  has_many :alunos, foreign_key: 'alu_tur_codigo', primary_key: 'tur_codigo', dependent: :nullify
  has_many :turma_x_eventos, foreign_key: 'TUR_CODIGO', primary_key: 'tur_codigo', dependent: :destroy
  has_many :eventos, through: :turma_x_eventos, source: :evento

  belongs_to :professor, class_name: 'User', foreign_key: 'user_id', optional: true

  serialize :tur_dia_da_semana, coder: JSON

  before_validation :limpar_dias_vazios

  def vagas_ocupadas
    alunos.count
  rescue
    0
  end

  def vagas_info
    cap = tur_capacidade || 0
    "#{vagas_ocupadas}/#{cap}"
  end

  private

  def limpar_dias_vazios
    if tur_dia_da_semana.is_a?(Array)
      self.tur_dia_da_semana = tur_dia_da_semana.reject(&:blank?)
    elsif tur_dia_da_semana.is_a?(String)
      self.tur_dia_da_semana = [tur_dia_da_semana].reject(&:blank?)
    end
  end

  def verificar_dias_da_semana
    dias_limpos = Array(tur_dia_da_semana).reject(&:blank?)
    if dias_limpos.empty?
      errors.add(:tur_dia_da_semana, "selecione pelo menos um dia da semana")
    end
  end
end