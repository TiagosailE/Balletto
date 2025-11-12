class UsersController < ApplicationController
  before_action :authenticate_admin!

  before_action :set_user, only: [:edit, :update, :destroy, :show]

  def index
    # Lista apenas os usuários com o papel de professor, ordenados por nome
    @users = User.where(role: :professor).order(:nome)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = :professor # Força que qualquer usuário criado aqui seja um professor

  if @user.save
    redirect_to users_path, notice: 'Professor cadastrado com sucesso.'
  else
    render :new, status: :unprocessable_entity # <-- Adicione esta parte
  end
end

  def edit; end

  def update
    params_to_update = user_params
    # Lógica para não obrigar a mudança de senha a cada edição
    if params_to_update[:password].blank?
      params_to_update.delete(:password)
    end

    if @user.update(params_to_update)
      redirect_to users_path, notice: 'Professor atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: 'Professor excluído com sucesso.'
  end

  private

  # Método de segurança personalizado
  def authenticate_admin!
    redirect_to root_path, alert: 'Acesso negado. Você não é um administrador.' unless current_user&.admin?
  end

  # Encontrar p usuário pelo ID da URL
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :nome, :usuario, :email, :password, :telefone,
      :date_cont, :status, :especialidades
    )
  end
end
