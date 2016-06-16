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
  post 'update_queues', to: 'queue_items#update_queues'
  resources :categories, only: [:show]
  resources :queue_items, only: [:create, :destroy]

  get 'register', to: 'users#new'
  get 'sign_in', to: 'sessions#new'
  get 'sign_out', to: 'sessions#destroy'
  resources :users, only: [:create, :show]

  get 'home', to: 'videos#index'
  resources :sessions, only: [:create]

  get '/people', to: 'relationships#index'
  resources :relationships, only: [:create, :destroy]

  get '/forgot_password', to: 'forgot_passwords#new'
  resources :forgot_passwords, only: [:create]
  get '/forgot_password_confirmation', to: 'forgot_passwords#confirm'

  resources :password_resets, only: [:show, :create]
  get '/invalid_token', to: 'password_resets#invalid_token'

  get '/invite', to: 'invitations#new'
  resources :invitations, only: [:create]
  get '/register/:token', to: 'users#new_with_invitation_token', as: 'register_with_token'

  namespace :admin do
    resources :videos, only: [:new, :create]
  end
end
