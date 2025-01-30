# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :reviews, only: [:index, :destroy, :edit, :update] do
      member do
        get :approve
      end
      resources :images, only: [:destroy]
    end
    resource :review_settings, only: [:edit, :update]
  end

  if SolidusSupport.api_available?
    namespace :api, defaults: { format: 'json' } do
      resources :reviews, only: [:show, :create, :update, :destroy] do
        member do
          post :set_positive_vote
          post :set_negative_vote
          post :flag_review
        end
      end

      resources :products do
        resources :reviews, only: [:index]
      end

      resources :users do
        resources :reviews, only: [:index]
      end
    end
  end
end
