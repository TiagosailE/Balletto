class AlunosController < ApplicationController
  before_action :authenticate_user!
  before_action :load_turmas, only: [:new, :edit, :create, :update]
  before_action :set_aluno, only: [:show, :edit, :update, :destroy]

  def index
    # Começa com a consulta base otimizada
    # Adicionamos .with_attached_foto para otimizar a lista
    @alunos = Aluno.includes(:turma).with_attached_foto.order(:alu_nome)
    
    # Filtra por nome se um parâmetro de busca for enviado
    if params[:query].present?
      # Usamos ILIKE para busca case-insensitive (funciona bem no PostgreSQL)
      @alunos = @alunos.where("alu_nome ILIKE ?", "%#{params[:query]}%")
    end
  end

  def show
    # @aluno é carregado pelo set_aluno
  end

  def new
    @aluno = Aluno.new
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
    # Garante que a foto seja carregada junto
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