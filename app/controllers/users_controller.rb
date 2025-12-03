class UsersController < ApplicationController
  
  before_action :authenticate_admin!
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = User.order(:usu_nome)

    if params[:query].present?
      query_term = "%#{params[:query]}%"
      @users = @users.where(
        "usu_nome ILIKE ? OR usu_login ILIKE ? OR email ILIKE ?",
        query_term, query_term, query_term
      )
    end

    respond_to do |format|
      format.html
      format.json do
        render json: @users.map { |u|
          {
            id: u.id,
            usu_nome: u.usu_nome,
            usu_login: u.usu_login,
            foto_url: u.foto.attached? ? url_for(u.foto) : nil,
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
      redirect_to root_path, notice: 'Usuário cadastrado com sucesso.', status: :see_other
    else
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
    if @user.id == current_user.id
      redirect_to configuracoes_path, alert: 'Você não pode excluir a si mesmo.', status: :see_other
      return
    end

    begin
      ActiveRecord::Base.transaction do
        alunos_count = Aluno.where(user_id: @user.id).update_all(user_id: current_user.id)
        
        Rails.logger.info "=== Reatribuídos #{alunos_count} alunos do usuário #{@user.id} para #{current_user.id} ==="

        @user.destroy!
      end
      
      redirect_to configuracoes_path, notice: 'Usuário excluído com sucesso.', status: :see_other
    rescue StandardError => e
      Rails.logger.error "=== Erro ao excluir usuário: #{e.message} ==="
      redirect_to configuracoes_path, alert: "Erro ao excluir usuário: #{e.message}", status: :see_other
    end
  end

  private

  def authenticate_admin!
    redirect_to root_path, alert: 'Acesso negado. Você não é um administrador.' unless current_user&.admin?
  end

  def set_user
    @user = User.find(params[:id])
  end

  def load_form_data
    @cargos = Cargo.order(:car_nome)
  end

  def user_params
    params.require(:user).permit(
      :usu_nome,
      :usu_login,
      :email,
      :password,
      :password_confirmation,
      :usu_telefone,
      :usu_data_contratacao,
      :usu_status,
      :usu_especialidades,
      :foto,
      cargo_ids: []
    )
  end
end