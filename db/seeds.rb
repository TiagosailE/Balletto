Cargo.destroy_all
Cargo.find_or_create_by!(car_nome: 'admin')
Cargo.find_or_create_by!(car_nome: 'professor')
Cargo.find_or_create_by!(car_nome: 'financeiro')
Cargo.find_or_create_by!(car_nome: 'atendimento')
puts "✓ Cargos criados"

admin_user = User.find_or_initialize_by(usu_login: 'admin')
admin_user.usu_nome = 'Admin'
admin_user.email = 'admin@gmail.com'
admin_user.password = '123456'
admin_user.password_confirmation = '123456'
admin_cargo = Cargo.find_by(car_nome: 'admin')
professor_cargo = Cargo.find_by(car_nome: 'professor')
admin_user.cargos = [admin_cargo, professor_cargo]

if admin_user.save
  puts "✓ Usuário admin criado"
else
  puts "ERRO: #{admin_user.errors.full_messages.join(', ')}"
end

Turma.destroy_all
Turma.create!(
  tur_nome: "Ballet Clássico - Intermediário I",
  tur_horario: Time.current.change(hour: 15, min: 0) + 2.days,
  tur_dia_da_semana: "Segunda-feira",
  tur_capacidade: 15,
  professor: admin_user
)

Turma.create!(
  tur_nome: "Jazz Infantil",
  tur_horario: Time.current.change(hour: 10, min: 0) + 1.week,
  tur_dia_da_semana: "Terça-feira",
  tur_capacidade: 10,
  professor: admin_user
)

Turma.create!(
  tur_nome: "Contemporâneo - Avançado",
  tur_horario: Time.current.change(hour: 19, min: 0) + 3.days,
  tur_dia_da_semana: "Quarta-feira",
  tur_capacidade: 12
)
puts "✓ Turmas criadas"

Caixa.destroy_all
Caixa.create!(
  cai_nome: "Caixa da Recepção",
  cai_tipo: "Caixa Físico",
  cai_saldo_inicial: 0.0
)
Caixa.create!(
  cai_nome: "Conta Bancária",
  cai_tipo: "Conta Corrente",
  cai_saldo_inicial: 0.0
)
puts "✓ Caixas criados"

if Configuracao.count.zero?
  Configuracao.create!(
    chave: "configuracao_principal",
    valor: "ativo",
    con_nome_academia: "Academia Balletto",
    con_valor_mensalidade: 120.00,
    dia_vencimento_mensalidade: 10
  )
  puts "✓ Configuração criada"
end

puts "\n✓ Seed concluído!"