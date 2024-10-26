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

  scope 'api' do
    resources :users, controller: :users, as: 'api_users'
    resources :api_keys, controller: :api_keys, as: 'api_api_keys'
    resources :machines, controller: :machines, as: 'api_machines'
  end

  get '/search', as: 'search', to: 'search#search'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
end
