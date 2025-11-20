class TurmasController < ApplicationController
  before_action :authenticate_user!
  before_action :set_turma, only: [:show, :edit, :update, :destroy, :alunos, :listar_alunos, :remover_aluno]
  before_action :set_professores, only: [:new, :edit, :create, :update, :show]

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
      redirect_to turmas_path, notice: "Turma criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @turma.update(turma_params)
      redirect_to turmas_path, notice: "Turma atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @turma.destroy
    redirect_to turmas_url, notice: "Turma excluída com sucesso."
  end
  
  def alunos
    @alunos = @turma.alunos

    respond_to do |format|
      format.html { render partial: "turmas/alunos_list", locals: { alunos: @alunos } }
      format.json { render json: @alunos }
    end
  end

  def listar_alunos
    alunos = @turma.alunos.with_attached_foto.order(:alu_nome).map do |aluno|
      status_colors = {
        'Ativo' => 'green',
        'Inativo' => 'red',
        'Pendente' => 'yellow'
      }
      color = status_colors[aluno.alu_status] || 'gray'
      
      {
        id: aluno.alu_codigo,
        nome: aluno.alu_nome,
        iniciais: aluno.alu_nome.split.map(&:first).join.upcase[0..1],
        data_cadastro: aluno.alu_data_cadastro&.strftime('%d/%m/%Y') || 'N/A',
        foto_url: aluno.foto.attached? ? url_for(aluno.foto.variant(resize_to_fill: [56, 56])) : nil,
        status_badge: "<span class='px-3 py-1 bg-#{color}-100 dark:bg-#{color}-900/30 text-#{color}-600 dark:text-#{color}-400 text-xs font-semibold rounded-full'>#{aluno.alu_status}</span>"
      }
    end

    render json: alunos
  end

  def remover_aluno
    aluno = Aluno.find(params[:aluno_id])
    
    if aluno.alu_tur_codigo == @turma.tur_codigo
      aluno.update(alu_tur_codigo: nil)
      alunos_count = @turma.alunos.count
      render json: { success: true, alunos_count: alunos_count }
    else
      render json: { success: false, error: 'Este aluno não pertence a esta turma' }
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, error: 'Aluno não encontrado' }
  rescue => e
    render json: { success: false, error: 'Erro ao remover aluno da turma' }
  end

  private

  def set_turma
    @turma = Turma.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to turmas_url, alert: "Turma não encontrada."
  end
  
  def turma_params
    # CORREÇÃO AQUI: 'tur_dia_da_semana' não é um array
    params.require(:turma).permit(:tur_nome, :tur_horario, :tur_capacidade, :user_id, :tur_dia_da_semana)
  end

  def set_professores
    # MUDANÇA PRINCIPAL AQUI:
    # 1. Filtra para encontrar usuários que TENHAM o cargo de 'professor'
    # 2. Ordena pela nova coluna 'usu_nome'
    @professores = User.joins(:cargos)
                       .where(cargos: { car_nome: 'professor' })
                       .order(:usu_nome)
  end
end