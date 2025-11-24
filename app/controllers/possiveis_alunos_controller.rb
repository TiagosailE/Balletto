class PossiveisAlunosController < ApplicationController
  before_action :set_possivel_aluno, only: %i[ edit update destroy ]

  # GET /possiveis_alunos
  def index
    @possiveis_alunos = PossivelAluno.all

    if params[:query].present?
      termo = "%#{params[:query]}%"
      
      # CORREÇÃO AQUI:
      # Adicionamos LOWER() no banco e comparamos com o termo também transformado
      @possiveis_alunos = @possiveis_alunos.where(
        "LOWER(pos_nome) LIKE LOWER(?) OR pos_telefone LIKE ?", 
        termo, termo
      )
    end

    @possiveis_alunos = @possiveis_alunos.order(created_at: :desc)
  end

  # GET /possiveis_alunos/new
  def new
    @possivel_aluno = PossivelAluno.new
  end

  # GET /possiveis_alunos/1/edit
  def edit
    # O @possivel_aluno já é encontrado pelo before_action lá embaixo
  end

  # POST /possiveis_alunos
  def create
    @possivel_aluno = PossivelAluno.new(possivel_aluno_params)

    if @possivel_aluno.save
      redirect_to possiveis_alunos_path, notice: "Novo interessado cadastrado com sucesso!"
    else
      # Se der erro, volta pro form mostrando os erros (status 422 é importante pro Rails novo)
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /possiveis_alunos/1
  def update
    if @possivel_aluno.update(possivel_aluno_params)
      redirect_to possiveis_alunos_path, notice: "Dados do interessado atualizados."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /possiveis_alunos/1
  def destroy
    @possivel_aluno.destroy
    redirect_to possiveis_alunos_path, notice: "Interessado removido da lista."
  end

  private
    # Use callbacks para compartilhar configurações comuns entre as ações.
    def set_possivel_aluno
      @possivel_aluno = PossivelAluno.find(params[:id])
    end

    # Strong Parameters: Aqui definimos o que pode ser salvo no banco (segurança)
    def possivel_aluno_params
      params.require(:possivel_aluno).permit(:pos_nome, :pos_telefone, :pos_email, :pos_observacao)
    end
end