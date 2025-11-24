# Be sure to restart your server when you modify this file.

ActiveSupport::Inflector.inflections(:en) do |inflect|
  # Ensina ao Rails que o plural de 'possivel_aluno' não é 'possiveis_aluno'
  inflect.irregular 'possivel_aluno', 'possiveis_alunos'
end