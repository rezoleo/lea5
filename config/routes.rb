# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get AUTH_CALLBACK_PATH, to: 'sessions#create', as: 'auth_callback'
  delete '/logout', to: 'sessions#destroy', as: 'logout'
  root 'static_pages#home'

  resources :users do
    resources :machines, shallow: true, except: [:index]
    # resources :subscriptions, shallow: true, only: [:new, :create]
    resources :sales, shallow: true, only: [:new, :create] do
      resources :refunds, shallow: true, only: [:new, :create]
    end
    # delete '/last_subscription', to: 'subscriptions#destroy', as: 'last_subscription'
    resources :free_accesses, shallow: true, except: [:index, :show]
  end

  namespace :admin do
    root 'dashboard#index'
    resources :articles, only: [:new, :create, :destroy]
    resources :subscription_offers, only: [:new, :create, :destroy]
    resources :payment_methods, only: [:new, :create, :destroy]
  end

  get '/search', as: 'search', to: 'search#search'
end
