Rails.application.routes.draw do
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post '/signup', to: 'users#create'
  post '/close', to: 'users#destroy'
  patch '/users/:id', to: 'users#update'
end
