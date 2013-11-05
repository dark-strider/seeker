Movie::Application.routes.draw do
  root to: 'movies#index'
  get ':id', to: 'movies#show', as: :movie
  get ':id/store/', to: 'movies#store'
end