class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    # 1. Card "Total de Alunos"
    @total_alunos = Aluno.count

    # 2. Card "Turmas Ativas"
    # (Vamos assumir que são todas as turmas cadastradas)
    @turmas_ativas = Turma.count 

    # 3. Card "Eventos Futuros" (Contagem)
    #    E Lista "Próximos Eventos" (para o card no final)
    #    (Assumindo que o modelo se chama Evento e a coluna de data EVE_DATA)
    @proximos_eventos = Evento.where("EVE_DATA >= ?", Date.today)
                              .order(EVE_DATA: :asc)
    
    @eventos_futuros_count = @proximos_eventos.count

    # 4. Card "Aniversariantes do Mês"
    #    (Assumindo que o modelo se chama Aluno e a coluna de data alu_data_nascimento)
    current_month = Date.today.month
    @aniversariantes = Aluno.where("extract(month from alu_data_nascimento) = ?", current_month)
                            .order(Arel.sql("extract(day from alu_data_nascimento) ASC"))
                            
    # 5. Card "Pagamentos Atrasados" (Estático por enquanto)
    #    (Você ainda não tem a tabela de pagamentos, então os dados
    #     do seu HTML estático serão usados)
  end
end