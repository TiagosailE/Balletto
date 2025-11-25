class Configuracao < ApplicationRecord
  self.table_name = 'configuracoes'

  validates :dia_vencimento_mensalidade, 
            numericality: { 
              only_integer: true, 
              greater_than_or_equal_to: 1, 
              less_than_or_equal_to: 31
            },
            allow_nil: true

  def self.instance
    first_or_create do |config|
      config.chave = "configuracao_principal"
      config.valor = "ativo"
      config.con_nome_academia = "Academia Balletto"
      config.con_valor_mensalidade = 120.00
      config.dia_vencimento_mensalidade = 10
    end
  end

  def con_valor_mensalidade
    read_attribute(:con_valor_mensalidade) || 120.00
  end

  def dia_vencimento_mensalidade
    read_attribute(:dia_vencimento_mensalidade) || 10
  end

  def con_nome_academia
    read_attribute(:con_nome_academia) || "Academia Balletto"
  end
end