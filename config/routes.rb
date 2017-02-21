Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :beers, only: [:index, :create], defaults: { format: "json" }
      resources :beer_types, only: [:index], defaults: { format: "json" }
      resources :users, only: [:create], defaults: { format: "json" }
      resources :authentication, only: [:create], defaults: { format: "json" }
    end
  end

  resources :approved_users, only: [:show]
end
