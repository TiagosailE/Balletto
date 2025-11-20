class UsersController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    # 1. Query Base
    @users = User.joins(:cargos)
                 .where(cargos: { car_nome: 'professor' })
                 .order(:usu_nome)
    
    # 2. Filtro de busca
    if params[:query].present?
      query_term = "%#{params[:query]}%"
      @users = @users.where(
        "usu_nome ILIKE ? OR usu_login ILIKE ? OR email ILIKE ?", 
        query_term, query_term, query_term
      )
    end

    # 3. RESPOSTA (HTML normal ou JSON para a modal)
    respond_to do |format|
      format.html # Renderiza index.html.erb normalmente
      format.json do
        # Monta o JSON manual para garantir que o JS receba o que precisa
        render json: @users.map { |u|
          {
            id: u.id,
            usu_nome: u.usu_nome,
            usu_login: u.usu_login,
            # Gera URL da foto se existir, senão manda null
            foto_url: u.foto.attached? ? url_for(u.foto) : nil,
            # Pega as duas primeiras letras do nome
            iniciais: u.usu_nome.split.map(&:first).join.upcase[0..1]
          }
        }
      end
    end
  end

  def new
    @user = User.new
    load_form_data
  end

  def create
    @user = User.new(user_params)
   
    if @user.save
      # CORREÇÃO: status: :see_other força o redirecionamento limpo
      redirect_to root_path, notice: 'Usuário cadastrado com sucesso.', status: :see_other
    else
      puts "ERROS DE VALIDAÇÃO: #{@user.errors.full_messages}" 
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_form_data

    render :new
  end

  def update
    params_to_update = user_params
    
    # Lógica para não obrigar a mudança de senha a cada edição
    if params_to_update[:password].blank?
      params_to_update.delete(:password)
      params_to_update.delete(:password_confirmation)
    end

    if @user.update(params_to_update)
      redirect_to configuracoes_path, notice: 'Usuário atualizado com sucesso.', status: :see_other
    else
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to configuracoes_path, notice: 'Usuário excluído com sucesso.', status: :see_other
  end

  private

  # Método de segurança personalizado
  def authenticate_admin!
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
      :foto,                 # <--- CORREÇÃO CRUCIAL: Adicionado :foto aqui!
      cargo_ids: []          # NOVO: permite um array de IDs de cargos
    )
  end
end