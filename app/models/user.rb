class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  # Pulamos :registerable, pois o admin que cadastra

  # --- Relação de Cargos (substitui o 'enum') ---
  # AVISO AQUI: Diga ao Rails o nome exato da nossa tabela de ligação
  has_and_belongs_to_many :cargos, join_table: 'cargos_usuarios'

  validates :usu_nome, presence: true
  validates :usu_login, presence: true, uniqueness: true
  
  # --- Métodos de Permissão ---
  def has_cargo?(nome_cargo)
    self.cargos.exists?(car_nome: nome_cargo)
  end

  def admin?
    has_cargo?('admin')
  end
  
  def professor?
    has_cargo?('professor')
  end
end