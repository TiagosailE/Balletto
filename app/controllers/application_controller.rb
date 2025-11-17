class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    
    devise_parameter_sanitizer.permit(:sign_in, keys: [:usu_login])

    devise_parameter_sanitizer.permit(:account_update, keys: [
      :usu_nome,
      :usu_login,
      :email,
      :password,
      :password_confirmation,
      :current_password
    ])
  end

  private

  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: 'Acesso negado. Você não tem permissão para realizar esta ação.'
    end
  end

end