# config/routes.rb
Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  resources :users
  resources :alunos

  resources :turmas do
    member do
      get :alunos
      get 'listar_alunos'
      delete 'remover_aluno/:aluno_id', action: :remover_aluno, as: :remover_aluno
    end
  end
  
  resources :eventos do
    member do
      get :turmas
      get 'turmas/:turma_id/alunos', to: 'eventos#alunos_turma'
      post 'turmas/:turma_id/alunos/:aluno_id/toggle', to: 'eventos#toggle_aluno'
    end
  end

  # Rota principal do financeiro
  get 'financeiro', to: 'financeiro#index', as: 'financeiro'
  
  # Rotas para ações do financeiro
  post 'financeiro/atualizar_valor_evento', to: 'financeiro#atualizar_valor_evento'
  get 'financeiro/participantes_evento/:evento_id', to: 'financeiro#participantes_evento'
  post 'financeiro/registrar_pagamento_evento', to: 'financeiro#registrar_pagamento_evento'
  post 'financeiro/atualizar_valor_mensalidade', to: 'financeiro#atualizar_valor_mensalidade'
  post 'financeiro/registrar_pagamento_mensalidade', to: 'financeiro#registrar_pagamento_mensalidade'
  post 'financeiro/registrar_despesa', to: 'financeiro#registrar_despesa'
  # Mantém as rotas de pagamentos para CRUD manual
  resources :pagamentos

  root 'home#index'

  get 'configuracoes', to: 'configuracoes#index', as: 'configuracoes'
  patch 'configuracoes', to: 'configuracoes#update'
  get 'configuracoes/listar_usuarios', to: 'configuracoes#listar_usuarios'
  delete 'configuracoes/excluir_usuario/:id', to: 'configuracoes#excluir_usuario'
end