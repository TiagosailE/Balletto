class Pagamento < ApplicationRecord
  self.primary_key = 'pag_codigo'

  # --- CORREÇÃO DAS RELAÇÕES ---
  # foreign_key: É o nome da coluna NESTA tabela (pagamentos) -> caixa_id
  # primary_key: É o nome da chave na OUTRA tabela (caixas) -> cai_codigo
  
  belongs_to :caixa, foreign_key: 'caixa_id', primary_key: 'cai_codigo'
  belongs_to :aluno, optional: true, foreign_key: 'aluno_id', primary_key: 'alu_codigo'
  belongs_to :evento, optional: true, foreign_key: 'evento_id', primary_key: 'EVE_CODIGO'

  # --- PLANO B: Substituindo os ENUMS ---
  
  TIPOS_PERMITIDOS = %w(Entrada Saída)
  STATUS_PERMITIDOS = %w(Pendente Pago Atrasado)

  validates :pag_tipo, inclusion: { 
    in: TIPOS_PERMITIDOS, 
    message: "%{value} não é um tipo válido" 
  }
  validates :pag_status, inclusion: { 
    in: STATUS_PERMITIDOS, 
    message: "%{value} não é um status válido" 
  }

  def self.tipos_para_select
    TIPOS_PERMITIDOS.map { |tipo| [tipo.capitalize, tipo] }
  end

  def self.statuses_para_select
    STATUS_PERMITIDOS.map { |status| [status.capitalize, status] }
  end
  
  # --- Validações ---
  validates :pag_data, presence: true
  validates :pag_valor, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Garante que o pagamento sempre tenha um caixa associado
  validates :caixa_id, presence: true

  # --- Helpers ---
  # Helper para saber se é entrada (usado na view para cor verde/vermelha)
  def entrada?
    pag_tipo == 'Entrada'
  end
end