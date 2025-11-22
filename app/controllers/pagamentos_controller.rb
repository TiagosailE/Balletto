# app/controllers/pagamentos_controller.rb
class PagamentosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pagamento, only: [:show, :edit, :update, :destroy]
  before_action :load_form_data, only: [:new, :edit, :create, :update]

  # GET /pagamentos (redireciona para financeiro)
  def index
    redirect_to financeiro_path
  end

  def show
    # Não vamos usar
  end

  def new
    @pagamento = Pagamento.new(pag_data: Time.current, pag_tipo: 'Entrada')
  end

  def edit
    # @pagamento já carregado
  end

  def create
    @pagamento = Pagamento.new(pagamento_params)

    if @pagamento.save
      redirect_to financeiro_path, notice: 'Lançamento criado com sucesso.'
    else
      flash.now[:alert] = 'Erro ao criar lançamento.'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @pagamento.update(pagamento_params)
      redirect_to financeiro_path, notice: 'Lançamento atualizado com sucesso.'
    else
      flash.now[:alert] = 'Erro ao atualizar lançamento.'
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pagamento.destroy
    redirect_to financeiro_path, notice: 'Lançamento excluído com sucesso.'
  end

  private
    
    def set_pagamento
      @pagamento = Pagamento.find(params[:id])
    end

    def load_form_data
      @caixas = Caixa.order(:cai_nome)
      @alunos = Aluno.order(:alu_nome)
      @eventos = Evento.order(:EVE_NOME)
    end

    def pagamento_params
      params.require(:pagamento).permit(
        :pag_data,
        :pag_valor,
        :pag_descricao,
        :pag_tipo,
        :pag_metodo,
        :pag_status,
        :caixa_id,
        :aluno_id,
        :evento_id
      )
    end
end