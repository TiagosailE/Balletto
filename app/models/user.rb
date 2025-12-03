class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  has_and_belongs_to_many :cargos, join_table: 'cargos_usuarios'
  has_one_attached :foto
  has_many :alunos, foreign_key: 'user_id', dependent: false
  validates :usu_nome, presence: true
  validates :usu_login, presence: true, uniqueness: true

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