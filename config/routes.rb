# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users do
    resources :machines, shallow: true
    resources :subscriptions, only: %i[new create edit]
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
