class EventosController < ApplicationController
  include Rails.application.routes.url_helpers
  
  before_action :authenticate_user!
  before_action :set_evento, only: %i[show edit update destroy turmas alunos_turma toggle_aluno]

  def index
    @eventos = Evento.all.order(EVE_DATA: :asc)
  end

  def show; end

  def new
    @evento = Evento.new
  end

  def edit; end

  def create
    @evento = Evento.new(evento_params.except(:turma_ids))

    if @evento.save
      atualizar_turmas_associadas(@evento)
      redirect_to eventos_path, notice: "Evento criado com sucesso!"
    else
      flash.now[:alert] = "Erro ao criar evento. Verifique os campos."
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @evento.update(evento_params.except(:turma_ids))
      atualizar_turmas_associadas(@evento)
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

  def alunos_turma
    turma = Turma.find(params[:turma_id])
    
    alunos = turma.alunos.with_attached_foto.map do |aluno|
      confirmado = EventoAlunoTurma.exists?(
        evento_id: @evento.EVE_CODIGO,
        turma_id: turma.tur_codigo,
        aluno_id: aluno.alu_codigo
      )
      
      {
        id: aluno.alu_codigo,
        nome: aluno.alu_nome,
        confirmado: confirmado,
        foto_url: aluno.foto.attached? ? url_for(aluno.foto.variant(resize_to_fill: [48, 48])) : nil
      }
    end
    
    render json: alunos
  end

  def toggle_aluno
    turma = Turma.find(params[:turma_id])
    aluno = Aluno.find(params[:aluno_id])
    
    registro = EventoAlunoTurma.find_by(
      evento_id: @evento.EVE_CODIGO,
      turma_id: turma.tur_codigo,
      aluno_id: aluno.alu_codigo
    )
    
    if registro
      registro.destroy
      render json: { confirmado: false }
    else
      EventoAlunoTurma.create!(
        evento_id: @evento.EVE_CODIGO,
        turma_id: turma.tur_codigo,
        aluno_id: aluno.alu_codigo
      )
      render json: { confirmado: true }
    end
  end

  private

  def set_evento
    @evento = Evento.find_by(EVE_CODIGO: params[:id])
  end

  def evento_params
    params.require(:evento).permit(:EVE_NOME, :EVE_LOCAL, :EVE_DATA, :EVE_DESC, turma_ids: [])
  end

  def atualizar_turmas_associadas(evento)
    turma_ids = Array(params.dig(:evento, :turma_ids)).reject(&:blank?)

    evento.turma_x_eventos.destroy_all

    turma_ids.each do |turma_id|
      TurmaXEvento.create!(
        EVE_CODIGO: evento.EVE_CODIGO,
        TUR_CODIGO: turma_id
      )
    end
  end
end