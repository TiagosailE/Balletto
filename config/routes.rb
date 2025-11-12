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
    get :alunos
  end
end

  root 'pages#home'
end
