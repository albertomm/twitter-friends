Rails.application.routes.draw do

  resources :users, param: :name, only: [:create, :show], format: false do
      resources :friends, param: :name, only: [:index, :create, :show, :destroy]
      resource :suggestions, only: [:show]
  end

end
