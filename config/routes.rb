# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :reviews, only: [:index, :destroy, :edit, :update] do
      member do
        get :approve
      end
      resources :feedback_reviews, only: [:index, :destroy]
      resources :images, only: [:destroy]
    end
    resource :review_settings, only: [:edit, :update]
  end

  resources :products, only: [] do
    resources :reviews, only: [:index, :new, :create, :edit, :update] do
    end
  end

  post '/reviews/:review_id/feedback(.:format)' => 'feedback_reviews#create', as: :feedback_reviews

  if Spree::Reviews::Config[:enable_reviews_feed]
    resource :reviews_feed, only: :show
  end

  if SolidusSupport.api_available?
    namespace :api, defaults: { format: 'json' } do
      resources :reviews, only: [:show, :create, :update, :destroy]

      resources :feedback_reviews, only: [:create, :update, :destroy]

      resources :products do
        resources :reviews, only: [:index]
      end

      resources :users do
        resources :reviews, only: [:index]
      end
    end
  end
end
