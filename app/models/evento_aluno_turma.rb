class EventoAlunoTurma < ApplicationRecord
  self.table_name = 'evento_aluno_turmas'
  
  belongs_to :evento, foreign_key: 'evento_id', primary_key: 'EVE_CODIGO'
  belongs_to :turma, foreign_key: 'turma_id', primary_key: 'tur_codigo'
  belongs_to :aluno, foreign_key: 'aluno_id', primary_key: 'alu_codigo'
  
  validates :evento_id, presence: true
  validates :turma_id, presence: true
  validates :aluno_id, presence: true
end