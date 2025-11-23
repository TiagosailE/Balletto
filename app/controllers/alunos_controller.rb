class AlunosController < ApplicationController
  before_action :authenticate_user!
  before_action :load_turmas, only: [:new, :edit, :create, :update, :index]
  before_action :set_aluno, only: [:show, :edit, :update, :destroy]

  def index
    @alunos = Aluno.includes(:turma).with_attached_foto.order(:alu_nome)
    @total_alunos = Aluno.count

    if params[:query].present?
      @alunos = @alunos.where("alu_nome ILIKE ?", "%#{params[:query]}%")
    end

    if params[:status].present? && params[:status] != ""
      @alunos = @alunos.where(alu_status: params[:status])
    end

    if params[:turma].present? && params[:turma] != ""
      @alunos = @alunos.where(alu_tur_codigo: params[:turma])
    end
  end

  def show
  end

  def new
    @aluno = Aluno.new

    if params[:nome].present?
      @aluno.alu_nome = params[:nome]
      @aluno.responsavel_telefone = params[:telefone]
      @aluno.responsavel_email = params[:email]
    end
  end

  def create
    @aluno = Aluno.new(aluno_params)
    @aluno.user = current_user

    if @aluno.save
      redirect_to @aluno, notice: 'Aluno cadastrado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @aluno.update(aluno_params)
      redirect_to @aluno, notice: 'Aluno atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @aluno.destroy
    redirect_to alunos_path, notice: 'Aluno excluído com sucesso.'
  end

  private

  def set_aluno
    @aluno = Aluno.with_attached_foto.find(params[:id])
  end

  def load_turmas
    @turmas = Turma.order(:tur_nome)
  end

  def aluno_params
    params.require(:aluno).permit(
      :alu_nome,
      :alu_data_nascimento,
      :alu_status,
      :alu_data_cadastro,
      :alu_endereco,
      :alu_tur_codigo,
      :responsavel_nome,
      :responsavel_telefone,
      :responsavel_email,
      :condicoes_medicas,
      :foto
    )
  end
end
