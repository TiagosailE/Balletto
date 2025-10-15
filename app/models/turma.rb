class Turma < ApplicationRecord
  self.table_name = 'turmas'
  self.primary_key = 'tur_codigo'

  validates :tur_nome, presence: true, length: { maximum: 50 }
  validates :tur_nivel, length: { maximum: 25 }, allow_blank: true
  validates :tur_capacidade, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to:255 }, allow_nil: true

  has_many :alunos, foreign_key: 'alu_tur_codigo', primary_key: 'tur_codigo', dependent: :nullify

  belongs_to :professor, class_name: 'User', foreign_key: 'user_id', optional: true

  def vagas_ocupadas
    alunos.count
  rescue
    0
  end

  def vagas_info
    cap = tur_capacidade || 0
    "#{vagas_ocupadas}/#{cap}"
  end
end