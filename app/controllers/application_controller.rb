class ApplicationController < ActionController::Base
  # A linha abaixo executa nosso método de permissão APENAS quando
  # um controller do Devise (login, cadastro, etc.) está ativo.
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected # <--- A palavra 'protected' é crucial para segurança e funcionamento!

  def configure_permitted_parameters
    # Permite o campo :usuario no formulário de login (sign_in)
    devise_parameter_sanitizer.permit(:sign_in, keys: [:usuario])

    # Permite campos extras no formulário de cadastro (sign_up)
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nome, :usuario, :email])

    # Permite campos extras ao editar a conta (account_update)
    devise_parameter_sanitizer.permit(:account_update, keys: [:nome, :usuario, :email])
  end
end