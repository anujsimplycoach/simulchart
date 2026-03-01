Rails.application.routes.draw do
  devise_for :users
  
  root 'dashboards#index'
  
  resources :dashboards, only: [:index, :new, :create, :show]

  mount ActionCable.server => '/cable'
end
