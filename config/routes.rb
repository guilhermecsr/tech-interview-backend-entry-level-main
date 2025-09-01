require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  resources :products
  resource :cart, only: [:show, :create]

  delete 'cart/:product_id', to: 'carts#destroy', as: :remove_from_cart

  post 'cart/add_item', to: 'carts#add_item'

  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
