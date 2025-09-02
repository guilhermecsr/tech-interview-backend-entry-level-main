require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  resources :products
  resource :cart, only: [:show, :create]

  delete 'cart/:product_id', to: 'carts#destroy'
  post 'cart/add_items', to: 'carts#add_item'

  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
