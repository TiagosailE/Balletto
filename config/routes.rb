Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  resources :users
  resources :alunos

  resources :turmas do
    member do
      get :alunos 
    end
  end
  
  resources :eventos do
    member do
      get :turmas
      get 'turmas/:turma_id/alunos', to: 'eventos#alunos_turma'
      post 'turmas/:turma_id/alunos/:aluno_id/toggle', to: 'eventos#toggle_aluno'
    end
  end

  root 'pages#home'
end