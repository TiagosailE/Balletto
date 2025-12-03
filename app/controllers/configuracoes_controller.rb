class ConfiguracoesController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
  end

  def update
    @user = current_user
    
    if user_params[:password].blank?
      params_without_password = user_params.except(:password, :password_confirmation)
      
      if @user.update(params_without_password)
        redirect_to configuracoes_path, notice: 'Configurações atualizadas com sucesso!'
      else
        render :index, status: :unprocessable_entity
      end
    else
      if @user.update(user_params)
        bypass_sign_in(@user)
        redirect_to configuracoes_path, notice: 'Configurações e senha atualizadas com sucesso!'
      else
        render :index, status: :unprocessable_entity
      end
    end
  end

  def listar_usuarios
    unless current_user.admin?
      render json: { error: 'Acesso negado' }, status: :forbidden
      return
    end

    users = User.all.map do |user|
      role_colors = {
        'admin' => 'purple',
        'financeiro' => 'green',
        'atendente' => 'blue',
        'professor' => 'teal'
      }
      color = role_colors[user.role] || 'teal'
      
      {
        id: user.id,
        nome: user.nome,
        usuario: user.usuario,
        role_texto: user.role.capitalize,
        iniciais: user.nome.split.map(&:first).join.upcase[0..1],
        is_current: user.id == current_user.id,
        foto_url: user.foto.attached? ? url_for(user.foto.variant(resize_to_fill: [56, 56])) : nil,
        role_badge: "<span class='px-3 py-1 bg-#{color}-100 dark:bg-#{color}-900/30 text-#{color}-600 dark:text-#{color}-400 text-xs font-semibold rounded-full'>#{user.role.capitalize}</span>"
      }
    end

    render json: users
  end

  def excluir_usuario
  unless current_user.admin?
    render json: { success: false, error: 'Acesso negado' }, status: :forbidden
    return
  end

  user = User.find(params[:id])
  
  if user.id == current_user.id
    render json: { success: false, error: 'Você não pode excluir a si mesmo' }
    return
  end

  begin
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute(
        "UPDATE alunos SET user_id = #{current_user.id} WHERE user_id = #{user.id}"
      )
      user.destroy!
    end
    
    render json: { success: true }
  rescue => e
    Rails.logger.error "Erro ao excluir usuário: #{e.message}"
    render json: { success: false, error: "Erro ao excluir usuário: #{e.message}" }
  end
end

  private

  def user_params
    params.require(:user).permit(:nome, :usuario, :telefone, :email, :password, :password_confirmation, :foto)
  end
end