# app/models/configuracao.rb
class Configuracao < ApplicationRecord
  self.table_name = 'configuracoes'  # ← ADICIONE ESTA LINHA
  
  validates :chave, presence: true, uniqueness: true
  
  # Método helper para pegar uma configuração
  def self.get(chave, default = nil)
    find_by(chave: chave)&.valor || default
  end
  
  # Método helper para setar uma configuração
  def self.set(chave, valor)
    config = find_or_initialize_by(chave: chave)
    config.valor = valor.to_s
    config.save
  end
  
  # Método específico para valor da mensalidade
  def self.valor_mensalidade
    valor = get('valor_mensalidade', '120.00')
    BigDecimal(valor.to_s)
  end
  
  def self.set_valor_mensalidade(valor)
    set('valor_mensalidade', valor)
  end
end