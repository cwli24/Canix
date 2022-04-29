Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'api/ping'
  get 'api/posts'

  # Defines the root path route ("/") & catch all
  root 'application#not_found'
  get '*unmatched_route', to: redirect('/'), status: :not_found
end
