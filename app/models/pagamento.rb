class Pagamento < ApplicationRecord
  self.primary_key = 'pag_codigo'
  
  belongs_to :caixa, foreign_key: 'caixa_id', primary_key: 'cai_codigo'
  belongs_to :aluno, foreign_key: 'aluno_id', primary_key: 'alu_codigo', optional: true
  belongs_to :evento, foreign_key: 'evento_id', primary_key: 'EVE_CODIGO', optional: true

  validates :pag_tipo, presence: true
  validates :pag_valor, presence: true, numericality: { greater_than: 0 }

  scope :entradas, -> { where(pag_tipo: 'Entrada') }
  scope :saidas, -> { where(pag_tipo: 'Saída') }
  scope :do_mes, ->(data = Date.current) { 
    where(pag_data: data.beginning_of_month..data.end_of_month) 
  }
  scope :mensalidades, -> { where("pag_descricao LIKE ?", "Mensalidade%") }
  scope :atrasados, -> { where(pag_status: 'Atrasado') }

  before_save :atualizar_status_pagamento

  def entrada?
    pag_tipo == 'Entrada'
  end

  def saida?
    pag_tipo == 'Saída'
  end

  def quitado?
    pag_status == 'Pago'
  end

  def valor_pendente
    return 0 if quitado?
    pag_valor - (pag_valor_pago || 0)
  end

  def mensalidade?
    pag_descricao&.include?('Mensalidade')
  end

  def data_vencimento
    return nil unless mensalidade?
    
    match = pag_descricao.match(/Mensalidade - (\d{2})\/(\d{4})/)
    return nil unless match
    
    mes = match[1].to_i
    ano = match[2].to_i
    dia_vencimento = Configuracao.instance.dia_vencimento_mensalidade
    
    Date.new(ano, mes, dia_vencimento)
  rescue
    nil
  end

  def dias_atraso
    return 0 if quitado? || data_vencimento.nil?
    dias = (Date.current - data_vencimento).to_i
    dias > 0 ? dias : 0
  end

  def atrasado?
    return false if quitado?
    data_vencimento.present? && Date.current > data_vencimento
  end

  def self.atualizar_status_mensalidades
    mensalidades.where.not(pag_status: 'Pago').find_each do |pagamento|
      pagamento.save
    end
  end

  private

  def atualizar_status_pagamento
    if mensalidade?
      if pag_valor_pago.present? && pag_valor_pago >= pag_valor
        self.pag_status = 'Pago'
      elsif atrasado?
        self.pag_status = 'Atrasado'
      else
        self.pag_status = 'Pendente'
      end
    end
  end
end