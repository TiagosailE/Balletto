class ApplicationController < ActionController::Base

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected 

  def configure_permitted_parameters

    devise_parameter_sanitizer.permit(:sign_in, keys: [:usuario])


    devise_parameter_sanitizer.permit(:sign_up, keys: [:nome, :usuario, :email])

    devise_parameter_sanitizer.permit(:account_update, keys: [:nome, :usuario, :email])
  end

  private

  def authorize_admin!
    unless current_user.admin?
      redirect_to root_path, alert: 'Acesso negado. Você não tem permissão para realizar esta ação.'
    end
  end

end