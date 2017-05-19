Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :reviews, only: [:index, :destroy, :edit, :update] do
      member do
        get :approve
      end
      resources :feedback_reviews, only: [:index, :destroy]
    end
    resource :review_settings, only: [:edit, :update]
  end

  resources :products, only: [] do
    resources :reviews, only: [:index, :new, :create] do
    end
  end
  post '/reviews/:review_id/feedback(.:format)' => 'feedback_reviews#create', as: :feedback_reviews

  if (
      SolidusSupport.api_available? &&
      Spree::Reviews::Config.draw_api_routes
  )
    namespace :api, defaults: { format: 'json'} do
      resources :reviews, only: [:show, :create, :update, :destroy]

      resources :products do
        resources :reviews, only: [:index]
      end

      resources :users do
        resources :reviews, only: [:index]
      end
    end
  end
end
