class TurmasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_turma, only: %i[ show edit update destroy alunos ]
  before_action :set_professores, only: %i[ new edit create update show ]

  def index
    @turmas = Turma.includes(:professor).order(:tur_nome)
  end

  def show
    @alunos = @turma.alunos
  end

  def new
    @turma = Turma.new
  end

  def edit
  end
  
  def create
    @turma = Turma.new(turma_params)

    if @turma.save
      redirect_to @turma, notice: "Turma criada com sucesso."
    else
      flash.now[:alert] = "Erro ao criar turma."
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @turma.update(turma_params)
      redirect_to @turma, notice: "Turma atualizada com sucesso."
    else
      flash.now[:alert] = "Erro ao atualizar turma."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @turma.destroy
    redirect_to turmas_url, notice: "Turma excluída com sucesso."
  end
  def alunos
    @turma = Turma.find(params[:id])
    @alunos = @turma.alunos

    respond_to do |format|
      format.html { render partial: "turmas/alunos_list", locals: { alunos: @alunos } }
      format.json { render json: @alunos }
    end
  end

  private

  def set_turma
    @turma = Turma.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to turmas_url, alert: "Turma não encontrada."
  end
  
  def turma_params
    params.require(:turma).permit(:tur_nome, :tur_horario, :tur_capacidade, :tur_dia_da_semana, :user_id)
  end

  def set_professores
    @professores = User.order(:nome)
  end
end
