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
  resource :mow_flow, only: [:show], controller: :mow_flow
  resources :calendar_week do
    collection do
      patch :sort
    end
  end

  get 'home', to: 'pages#home', as: 'home'
  get 'dashboard', to: 'pages#dashboard', as: 'dashboard'
  get 'my_business', to: 'businesses#show', as: 'my_business'
  get 'client_jobs/:id', to: 'scheduled_locations#client_jobs', as: 'client_jobs'
  get 'reschedule_job/:id', to: 'scheduled_locations#reschedule_job', as: 'reschedule_job'
  patch 'reschedule_job/:id', to: 'scheduled_locations#reschedule_job_update', as: 'reschedule_job_update'
  post 'mow_flow_opto', to: 'mow_flow#optimize_list', as: 'mow_flow_opto'
  get 'new_depot', to: 'scheduled_locations#new_depot', as: 'new_depot'
  post 'create_depot', to: 'scheduled_locations#create_depot', as: 'create_depot'
  get 'edit_depot', to: 'scheduled_locations#edit_depot', as: 'edit_depot'
  patch 'update_depot', to: 'scheduled_locations#update_depot', as: 'update_depot'
  get 'login' => 'user_sessions#new', :as => :login
  post 'logout' => 'user_sessions#destroy', :as => :logout
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
