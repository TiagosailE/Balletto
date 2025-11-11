class EventosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_evento, only: %i[show edit update destroy turmas alunos]

  def index
    @eventos = Evento.all.order(EVE_DATA: :asc)
  end

  def show; end

  def new
    @evento = Evento.new
  end

  def edit; end

  def create
    @evento = Evento.new(evento_params)
    if @evento.save
      redirect_to eventos_path, notice: "Evento criado com sucesso!"
    else
      flash.now[:alert] = "Erro ao criar evento. Verifique os campos."
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @evento.update(evento_params)
      redirect_to eventos_path, notice: "Evento atualizado com sucesso!"
    else
      flash.now[:alert] = "Erro ao atualizar evento."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @evento.destroy
    redirect_to eventos_path, notice: "Evento removido com sucesso."
  end

  def turmas
    turmas = @evento.turmas.select(:tur_codigo, :tur_nome, :tur_dia_da_semana, :tur_horario)
    render json: turmas
  end

  def alunos
    turma = Turma.find(params[:turma_id])
    alunos = turma.alunos.select(:alu_codigo, :alu_nome)
    render json: alunos.map { |a| { alu_codigo: a.alu_codigo, alu_nome: a.alu_nome, confirmado: false } }
  end

  private

  def set_evento
    @evento = Evento.find_by(EVE_CODIGO: params[:id])
  end

  def evento_params
    params.require(:evento).permit(:EVE_NOME, :EVE_LOCAL, :EVE_DATA, :EVE_DESC, turma_ids: [])
  end
end
