Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  resources :vinyl, only:[:show, :index]
  resources :artist, only:[:show]
  resources :wishlist, only:[:show, :update]
  resources :collection, only:[:show, :update] do
    resources :playlist, only:[:show, :update, :destroy, :create, :new]
  end
  resources :chat, only:[:show, :destroy, :create] do
    resources :message, only:[:create]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
