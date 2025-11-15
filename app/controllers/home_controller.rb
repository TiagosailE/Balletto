class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_alunos = Aluno.count
    
    @turmas_ativas = Turma.count
    
    mes_atual = Date.today.month
    @aniversariantes = Aluno
      .where("EXTRACT(MONTH FROM alu_data_nascimento) = ?", mes_atual)
      .order(Arel.sql("EXTRACT(DAY FROM alu_data_nascimento)"))
      .limit(5)
    
    @eventos_futuros_count = Evento.where('"EVE_DATA" >= ?', Date.today).count
    
    @proximos_eventos = Evento
      .where('"EVE_DATA" >= ?', Date.today)
      .order('"EVE_DATA" ASC')
      .limit(8)
  end
end