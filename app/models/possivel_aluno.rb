class PossivelAluno < ApplicationRecord
  validates :pos_nome, presence: { message: "é obrigatório" }
  validates :pos_telefone, presence: { message: "é necessário para contato" }
end