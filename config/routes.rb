Rails.application.routes.draw do
  namespace :api do
    namespace :v1, format: "json" do
      resources :beers, only: [:index, :create]
      resources :ratings, only: [:create]
      resources :beer_types, only: [:index]
      resources :users, only: [:create]
      resources :authentication, only: [:create]
    end
  end

  get "approved_users", to: "approved_users#show"
end
