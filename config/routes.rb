Rails.application.routes.draw do
  root :to => 'pages#home'
  resources :user_sessions
  resources :users

  get 'home', to: 'pages#home', as: 'home'
  get 'dashboard', to: 'pages#dashboard', as: 'dashboard'
  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
