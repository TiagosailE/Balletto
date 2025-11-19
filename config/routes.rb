Rails.application.routes.draw do
  get "pagamentos/index"
  get "pagamentos/new"
  get "pagamentos/create"
  get "pagamentos/edit"
  get "pagamentos/update"
  get "pagamentos/destroy"
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

  resources :pagamentos

  root 'home#index'

  get 'configuracoes', to: 'configuracoes#index', as: 'configuracoes'
  patch 'configuracoes', to: 'configuracoes#update'
  get 'configuracoes/novo_usuario', to: 'configuracoes#novo_usuario', as: 'novo_usuario'
  post 'configuracoes/criar_usuario', to: 'configuracoes#criar_usuario'
  get 'configuracoes/listar_usuarios', to: 'configuracoes#listar_usuarios'
  delete 'configuracoes/excluir_usuario/:id', to: 'configuracoes#excluir_usuario'
end