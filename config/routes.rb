Myflix::Application.routes.draw do
  get 'ui(/:action)', controller: 'ui'

  root to: 'pages#front'

  resources :videos, only: [:show] do
    collection do
      get 'search', to: 'videos#search'
    end

    resources :reviews, only: [:create]
  end

  get 'my_queue', to: 'queue_items#index'
  resources :categories, only: [:show]
  resources :queue_items, only: [:create, :destroy]

  get 'register', to: 'users#new'
  get 'sign_in', to: 'sessions#new'
  get 'sign_out', to: 'sessions#destroy'
  resources :users, only: [:create]

  get 'home', to: 'videos#index'
  resources :sessions, only: [:create]
end
