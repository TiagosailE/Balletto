Rails.application.routes.draw do

  devise_for :users, skip: [:registrations]

  resources :users
  resources :turmas
  resources :alunos
  
  root 'pages#home'
end
