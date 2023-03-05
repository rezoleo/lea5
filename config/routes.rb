# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get AUTH_CALLBACK_PATH, to: 'sessions#create', as: 'auth_callback'
  delete '/logout', to: 'sessions#destroy', as: 'logout'

  resources :users do
    resources :machines, shallow: true, except: [:index]
    resources :subscriptions, shallow: true, only: %i[new create]
    delete '/last_subscription', to: 'subscriptions#destroy', as: 'last_subscription'
    resources :free_accesses, shallow: true, except: %i[index show]
  end
end
