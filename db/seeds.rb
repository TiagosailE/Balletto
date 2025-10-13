Turma.destroy_all

Turma.create!(
  tur_nome: "Ballet Clássico - Intermediário I",
  tur_horario: Time.current.change(hour: 15, min: 0) + 2.days,
  tur_nivel: "Intermediário",
  tur_capacidade: 15
)

Turma.create!(
  tur_nome: "Jazz Infantil",
  tur_horario: Time.current.change(hour: 10, min: 0) + 1.week,
  tur_nivel: "Infantil",
  tur_capacidade: 10
)

Turma.create!(
  tur_nome: "Contemporâneo - Avançado",
  tur_horario: Time.current.change(hour: 19, min: 0) + 3.days,
  tur_nivel: "Avançado",
  tur_capacidade: 12
)