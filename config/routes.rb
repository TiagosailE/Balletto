Rails.application.routes.draw do
  root 'turmas#index'
  resources :turmas
end
