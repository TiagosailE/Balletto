Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  resources :users
  resources :alunos
  resources :possiveis_alunos

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
  get 'financeiro', to: 'financeiro#index', as: 'financeiro'
  
  post 'financeiro/atualizar_valor_evento', to: 'financeiro#atualizar_valor_evento'
  get 'financeiro/participantes_evento/:evento_id', to: 'financeiro#participantes_evento'
  post 'financeiro/registrar_pagamento_evento', to: 'financeiro#registrar_pagamento_evento'
  post 'financeiro/atualizar_valor_mensalidade', to: 'financeiro#atualizar_valor_mensalidade'
  post 'financeiro/registrar_pagamento_mensalidade', to: 'financeiro#registrar_pagamento_mensalidade'
  post 'financeiro/registrar_despesa', to: 'financeiro#registrar_despesa'
 get 'financeiro/info_mensalidade_aluno/:aluno_id', to: 'financeiro#info_mensalidade_aluno' 
  resources :pagamentos

  root 'home#index'

  get 'configuracoes', to: 'configuracoes#index', as: 'configuracoes'
  patch 'configuracoes', to: 'configuracoes#update'
  get 'configuracoes/listar_usuarios', to: 'configuracoes#listar_usuarios'
  delete 'configuracoes/excluir_usuario/:id', to: 'configuracoes#excluir_usuario'
end