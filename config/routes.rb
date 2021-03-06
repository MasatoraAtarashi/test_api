Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post '/signup', to: 'users#create'
  get 'users/:user_id', to: 'users#show'
  patch '/users/:user_id', to: 'users#update'
  post '/close', to: 'users#destroy'
  resources :users
end
