class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # Permite login com usu_login
    devise_parameter_sanitizer.permit(:sign_in, keys: [:usu_login])

    # Lista de campos personalizados do seu banco
    custom_keys = [
      :usu_nome,
      :usu_login,
      :usu_telefone,
      :usu_data_contratacao,
      :usu_status,
      :usu_especialidades,
      :foto
    ]

    # Permite esses campos no Cadastro (Sign Up) - caso use registro público
    devise_parameter_sanitizer.permit(:sign_up, keys: custom_keys)

    # Permite esses campos na Edição de Conta (Account Update)
    devise_parameter_sanitizer.permit(:account_update, keys: custom_keys)
  end

  private

  def authorize_admin!
    # O '&.' previne erro se o usuário não estiver logado (current_user nil)
    unless current_user&.admin?
      redirect_to root_path, alert: 'Acesso negado. Você não tem permissão para realizar esta ação.'
    end
  end
end