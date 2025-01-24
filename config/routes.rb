# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get AUTH_CALLBACK_PATH, to: 'sessions#create', as: 'auth_callback'
  delete '/logout', to: 'sessions#destroy', as: 'logout'
  root 'static_pages#home'

  resources :users do
    resources :machines, shallow: true, except: [:index]
    resources :subscriptions, shallow: true, only: [:new, :create]
    delete '/last_subscription', to: 'subscriptions#destroy', as: 'last_subscription'
    resources :free_accesses, shallow: true, except: [:index, :show]
  end

  resources :api_keys

  get '/search', as: 'search', to: 'search#search'

  get "#{API_PATH}/users", to: 'api_users#index'
  get "#{API_PATH}/users/:id", to: 'api_users#show'
  get "#{API_PATH}/machines/:id", to: 'api_machines#show'
  get "#{API_PATH}/api_keys", to: 'api_api_keys#index'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
end
