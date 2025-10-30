class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { professor: 0, admin: 1 }

  validates :nome, presence: true
  validates :usuario, presence: true, uniqueness: true

  has_many :turmas, foreign_key: 'user_id', dependent: :nullify
end