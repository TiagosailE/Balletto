class EventoAlunoTurma < ApplicationRecord
  belongs_to :evento
  belongs_to :turma
  belongs_to :aluno
end