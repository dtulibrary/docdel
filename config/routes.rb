Haitatsu::Application.routes.draw do
  root :to => 'home#index'

  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :rest do
    resources :orders, :only => [:show, :create]
  end

end
