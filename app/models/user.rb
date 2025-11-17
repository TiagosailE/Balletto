class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { 
    professor: 0, 
    admin: 1,
    financeiro: 2,
    atendente: 3
  }

  has_one_attached :foto

  validates :nome, presence: true
  validates :usuario, presence: true, uniqueness: true
  validate :foto_formato_valido

  has_many :turmas, foreign_key: 'user_id', dependent: :nullify

  private

  def foto_formato_valido
    return unless foto.attached?

    unless foto.content_type.in?(%w[image/jpeg image/jpg image/png image/gif])
      errors.add(:foto, 'deve ser uma imagem JPEG, PNG ou GIF')
      foto.purge
    end
  end
end