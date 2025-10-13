class TurmasController < ApplicationController
  before_action :set_turma, only: %i[ show edit update destroy ]

  def index
    @turmas = Turma.order(:tur_nome).all
  end

  def show
    # @Turma carregado em set_turma
    # @alunos placeholder: se houver modelo Aluno, a associação trará os registros relacionados
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

  private

  def set_turma
    @turma = Turma.find(params[:id])

  rescue ActiveRecord::RecordNotFound
    redirect_to turmas_url, alert: "Turma não encontrada."
  end
  
  def turma_params
    params.require(:turma).permit(:tur_nome, :tur_horario, :tur_nivel, :tur_capacidade, :tur_dia_da_semana)
  end
end