class UsersController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_user, only: [:edit, :update, :destroy, :show]

  def index
    # 1. Começa com a consulta base (todos os professores)
    @users = User.joins(:cargos)
                 .where(cargos: { car_nome: 'professor' })
                 .order(:usu_nome)
    
    # 2. ADICIONA O FILTRO DE BUSCA:
    if params[:query].present?
      # Prepara a query (ILIKE ignora maiúsculas/minúsculas)
      query_term = "%#{params[:query]}%"
      
      # Busca pelo nome, login ou email DENTRO da lista de professores
      @users = @users.where(
        "usu_nome ILIKE ? OR usu_login ILIKE ? OR email ILIKE ?", 
        query_term, query_term, query_term
      )
    end
  end

  def new
    @user = User.new
    load_form_data
  end

  def create
    @user = User.new(user_params)
   
    if @user.save
      redirect_to users_path, notice: 'Usuário cadastrado com sucesso.'
    else
      # Precisamos recarregar os dados do formulário em caso de falha
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # Carrega os dados para os checkboxes de cargos
    load_form_data
  end

  def update
    params_to_update = user_params
    
    # Lógica para não obrigar a mudança de senha a cada edição
    if params_to_update[:password].blank?
      params_to_update.delete(:password)
      params_to_update.delete(:password_confirmation) # Garante que a confirmação também seja removida
    end

    if @user.update(params_to_update)
      redirect_to users_path, notice: 'Usuário atualizado com sucesso.'
    else
      # Precisamos recarregar os dados do formulário em caso de falha
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: 'Usuário excluído com sucesso.'
  end

  private

  # Método de segurança personalizado
  def authenticate_admin!
    # Esta verificação continua funcionando, pois atualizamos o User.admin? no modelo
    redirect_to root_path, alert: 'Acesso negado. Você não é um administrador.' unless current_user&.admin?
  end

  # Encontra o usuário pelo ID da URL
  def set_user
    @user = User.find(params[:id])
  end

  # Novo método para carregar os cargos para o formulário
  def load_form_data
    @cargos = Cargo.order(:car_nome)
  end

  # Parâmetros permitidos ATUALIZADOS para a nova estrutura
  def user_params
    params.require(:user).permit(
      :usu_nome,             # :nome
      :usu_login,            # :usuario
      :email,                # mantido (devise)
      :password,             # mantido (devise)
      :password_confirmation,
      :usu_telefone,         # :telefone
      :usu_data_contratacao, # :data_cont
      :usu_status,           # :status
      :usu_especialidades,   # :especialidades
      cargo_ids: []          # NOVO: permite um array de IDs de cargos
    )
  end
end