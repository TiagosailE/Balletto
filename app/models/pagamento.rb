class Pagamento < ApplicationRecord
  self.primary_key = 'pag_codigo'

  belongs_to :caixa, foreign_key: 'caixa_id', primary_key: 'cai_codigo'
  belongs_to :aluno, optional: true, foreign_key: 'aluno_id', primary_key: 'alu_codigo'
  belongs_to :evento, optional: true, foreign_key: 'evento_id', primary_key: 'EVE_CODIGO'

  TIPOS_PERMITIDOS = %w(Entrada Saída)
  STATUS_PERMITIDOS = %w(Pendente Pago Atrasado)

  validates :pag_tipo, inclusion: { 
    in: TIPOS_PERMITIDOS, 
    message: "%{value} não é um tipo válido" 
  }
  validates :pag_status, inclusion: { 
    in: STATUS_PERMITIDOS, 
    message: "%{value} não é um status válido" 
  }, allow_blank: true  # ← ADICIONE ESTA LINHA

  def self.tipos_para_select
    TIPOS_PERMITIDOS.map { |tipo| [tipo.capitalize, tipo] }
  end

  def self.statuses_para_select
    STATUS_PERMITIDOS.map { |status| [status.capitalize, status] }
  end
  
  validates :pag_data, presence: true
  validates :pag_valor, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :pag_valor_pago, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :caixa_id, presence: true

  # Calcula quanto falta pagar
  def valor_pendente
    (pag_valor || 0) - (pag_valor_pago || 0)
  end

  # Verifica se está quitado
  def quitado?
    valor_pendente <= 0
  end

  # Atualiza o status baseado no valor pago
  before_validation :atualizar_status  # ← MUDEI DE before_save PARA before_validation
  
  def atualizar_status
    if quitado?
      self.pag_status = 'Pago'
    elsif pag_valor_pago && pag_valor_pago > 0
      self.pag_status = 'Pendente'
    else
      self.pag_status = 'Pendente'  # ← DEFINE PENDENTE COMO PADRÃO
    end
  end

  def entrada?
    pag_tipo == 'Entrada'
  end
end