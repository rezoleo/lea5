# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users do
    resources :machines, shallow: true
    resources :subscriptions, only: %i[new create], shallow: true
    delete '/subscriptions', to: 'subscriptions#destroy', as: :subscription
  end

  get '/subscriptions', to: 'subscriptions#index', as: :subscriptions

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
