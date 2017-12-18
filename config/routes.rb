Rails.application.routes.draw do
  get 'calendar_week/show'

  get 'calendar/show'

  root :to => 'pages#home'
  resources :user_sessions
  resources :users
  resources :businesses, shallow: true do
    resources :user_businesses
  end
  resources :clients
  resources :scheduled_locations
  resource :calendar, only: [:show], controller: :calendar
  resource :calendar_week, only: [:show], controller: :calendar_week
  resource :mow_flow, only: [:show], controller: :mow_flow

  get 'home', to: 'pages#home', as: 'home'
  get 'dashboard', to: 'pages#dashboard', as: 'dashboard'
  get 'my_business', to: 'businesses#show', as: 'my_business'
  get 'client_jobs/:id', to: 'scheduled_locations#client_jobs', as: 'client_jobs'
  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
