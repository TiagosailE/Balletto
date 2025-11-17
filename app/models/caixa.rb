class Caixa < ApplicationRecord
  self.primary_key = 'cai_codigo'

  # Um caixa (conta) tem muitos lançamentos (pagamentos)
  has_many :pagamentos, foreign_key: 'cai_codigo'

  validates :cai_nome, presence: true
end