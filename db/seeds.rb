# Este arquivo é executado com o comando `rails db:seed`
# Use-o para popular o banco de dados com dados iniciais essenciais.

# 1. Criar os Cargos Essenciais
puts "Limpando cargos antigos e criando novos..."
Cargo.destroy_all
Cargo.find_or_create_by!(car_nome: 'admin')
Cargo.find_or_create_by!(car_nome: 'professor')
Cargo.find_or_create_by!(car_nome: 'financeiro')
Cargo.find_or_create_by!(car_nome: 'atendimento')
puts "Cargos criados com sucesso!"

# 2. Criar o primeiro Usuário Administrador (que também é professor)
puts "Criando usuário admin..."
admin_user = User.find_or_initialize_by(usu_login: 'admin')

# Define/atualiza os dados
admin_user.usu_nome = 'Admin'
admin_user.email = 'admin@gmail.com'
admin_user.password = '123456'
admin_user.password_confirmation = '123456'

# Atribui os cargos de "admin" E "professor"
admin_cargo = Cargo.find_by(car_nome: 'admin')
professor_cargo = Cargo.find_by(car_nome: 'professor')
admin_user.cargos = [admin_cargo, professor_cargo]

if admin_user.save
  puts "Usuário admin 'admin' criado/atualizado com sucesso!"
else
  puts "ERRO ao criar admin: #{admin_user.errors.full_messages.join(', ')}"
end

# 3. Criar Turmas de Exemplo (do seu código)
puts "\nLimpando turmas antigas..."
Turma.destroy_all

puts "Criando turmas de exemplo..."
Turma.create!(
  tur_nome: "Ballet Clássico - Intermediário I",
  tur_horario: Time.current.change(hour: 15, min: 0) + 2.days,
  tur_dia_da_semana: "Segunda-feira", # Campo que faltava
  tur_capacidade: 15,
  professor: admin_user # Atribui o admin como professor
)

Turma.create!(
  tur_nome: "Jazz Infantil",
  tur_horario: Time.current.change(hour: 10, min: 0) + 1.week,
  tur_dia_da_semana: "Terça-feira", # Campo que faltava
  tur_capacidade: 10,
  professor: admin_user # Atribui o admin como professor
)

Turma.create!(
  tur_nome: "Contemporâneo - Avançado",
  tur_horario: Time.current.change(hour: 19, min: 0) + 3.days,
  tur_dia_da_semana: "Quarta-feira", # Campo que faltava
  tur_capacidade: 12
  # Deixando esta sem professor (opcional)
)

puts "Turmas de exemplo criadas!"
puts "\nSeed concluído!"