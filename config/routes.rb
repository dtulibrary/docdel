Docdel::Application.routes.draw do
  root :to => 'home#index'

  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  resources :orders, :only => [:show]
  post 'orders/:id/not_available' => 'orders#not_available', :as => 'order_not_available'

  namespace :rest do
    resources :orders, :only => [:show, :create]
    get 'test' => 'orders#test' if Rails.env.development?
  end

end
