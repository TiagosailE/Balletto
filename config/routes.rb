Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  resources :users

  resources :turmas
  
  root 'pages#home'
end
