# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users do
    resources :machines, shallow: true
    resources :subscriptions, only: %i[new create], shallow: true
    get '/subscriptions/edit', to: 'subscriptions#edit', as: :edit_subscription
    patch '/subscriptions', to: 'subscriptions#update', as: :subscription
    delete '/subscriptions', to: 'subscriptions#destroy'
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
