class PagamentosController < ApplicationController
  before_action :authenticate_user! # Garante que o usuário está logado
  before_action :set_pagamento, only: [:show, :edit, :update, :destroy]
  before_action :load_form_data, only: [:new, :edit, :create, :update]

  # GET /pagamentos (O nosso "Extrato")
  def index
    # Busca todos os pagamentos, dos mais recentes para os mais antigos
    # O .includes evita 1000 buscas ao banco (N+1 query)
    @pagamentos = Pagamento.includes(:caixa, :aluno, :evento)
                           .order(pag_data: :desc)
                           
    # Calcula os saldos totais para os cards
    @saldo_total = Caixa.sum("cai_saldo_inicial") + Pagamento.where(pag_tipo: 'Entrada').sum(:pag_valor) - Pagamento.where(pag_tipo: 'Saída').sum(:pag_valor)
    @total_entradas = Pagamento.where(pag_tipo: 'Entrada').sum(:pag_valor)
    @total_saidas = Pagamento.where(pag_tipo: 'Saída').sum(:pag_valor)
  end

  # GET /pagamentos/1
  def show
    # (Não vamos usar essa página por enquanto)
  end

  # GET /pagamentos/new
  def new
    @pagamento = Pagamento.new(pag_data: Time.current, pag_tipo: 'Entrada') # Padrão
  end

  # GET /pagamentos/1/edit
  def edit
    # @pagamento e @... já foram carregados pelos before_action
  end

  # POST /pagamentos
  def create
    @pagamento = Pagamento.new(pagamento_params)

    if @pagamento.save
      redirect_to pagamentos_path, notice: 'Lançamento criado com sucesso.'
    else
      flash.now[:alert] = 'Erro ao criar lançamento.'
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /pagamentos/1
  def update
    if @pagamento.update(pagamento_params)
      redirect_to pagamentos_path, notice: 'Lançamento atualizado com sucesso.'
    else
      flash.now[:alert] = 'Erro ao atualizar lançamento.'
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /pagamentos/1
  def destroy
    @pagamento.destroy
    redirect_to pagamentos_path, notice: 'Lançamento excluído com sucesso.'
  end

  private
    
    def set_pagamento
      @pagamento = Pagamento.find(params[:id])
    end

    # Carrega os dados para os dropdowns do formulário
    def load_form_data
      @caixas = Caixa.order(:cai_nome)
      @alunos = Aluno.order(:alu_nome)
      @eventos = Evento.order(:EVE_NOME)
    end

    # Define os parâmetros permitidos (segurança)
    def pagamento_params
      params.require(:pagamento).permit(
        :pag_data,
        :pag_valor,
        :pag_descricao,
        :pag_tipo,
        :pag_metodo,
        :pag_status,
        :caixa_id,   # Chave estrangeira para Caixa
        :aluno_id,   # Chave estrangeira para Aluno
        :evento_id   # Chave estrangeira para Evento
      )
    end
end