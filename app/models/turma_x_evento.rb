class TurmaXEvento < ApplicationRecord
  self.table_name = 'turma_x_eventos'

  belongs_to :evento, foreign_key: 'EVE_CODIGO', primary_key: 'EVE_CODIGO'
  belongs_to :turma, foreign_key: 'TUR_CODIGO', primary_key: 'tur_codigo'
end
