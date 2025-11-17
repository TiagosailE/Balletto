class Cargo < ApplicationRecord
  self.primary_key = 'car_codigo'
  
  has_and_belongs_to_many :users, join_table: 'cargos_usuarios'

  validates :car_nome, presence: true, uniqueness: true
end