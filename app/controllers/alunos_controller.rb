class AlunosController < ApplicationController
  before_action :authenticate_user!

  # Agora só precisamos carregar as Turmas para o formulário
  before_action :load_turmas, only: [:new, :edit, :create, :update]

  before_action :set_aluno, only: [:show, :edit, :update, :destroy]

  def index
    @alunos = Aluno.includes(:turma).order(:alu_nome)
  end

  def show
    # @aluno é carregado
  end

  def new
    @aluno = Aluno.new
  end

  def create
    @aluno = Aluno.new(aluno_params)
    @aluno.user = current_user # Atribui o usuário logado como o criador

    if @aluno.save
      redirect_to @aluno, notice: 'Aluno cadastrado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # @aluno é carregado
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
    @aluno = Aluno.find(params[:id])
  end

  # Método simplificado
  def load_turmas
    @turmas = Turma.order(:tur_nome)
  end

  # Parâmetros simplificados
  def aluno_params
    params.require(:aluno).permit(
      :alu_nome,
      :alu_data_nascimento,
      :alu_status,
      :alu_data_cadastro,
      :alu_endereco,
      :alu_tur_codigo,

      # Nossos novos campos de texto simples
      :responsavel_nome,
      :responsavel_telefone,
      :responsavel_email,
      :condicoes_medicas
    )
  end
end