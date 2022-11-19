# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get AUTH_CALLBACK_PATH, to: 'sessions#create', as: 'auth_callback'

  resources :users do
    resources :machines, shallow: true
  end
end
