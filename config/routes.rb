Rails.application.routes.draw do
  get 'search/index'
  devise_for :users
  root to: "pages#home"
  resources :vinyls, only:[:show, :index]
  resources :artists, only:[:show]
  # resources :wishlists, only:[:show, :update]
  # resources :collections, only:[:show,  :update] do
  #   resources :playlists, only:[:show, :update, :destroy, :create, :new]
  # end
  resources :chats, only:[:show, :destroy, :create] do
    resources :messages, only:[:create]
  end

  resources :users do
    collection do
      get :collection
      get :wishlist
    end
  end

  resources :search, only: [:index]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
