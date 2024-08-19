Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "health" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  
  get '/weather/current', to: 'weathers#current'
  get '/weather/historical', to: 'weathers#historical'
  get '/weather/historical/max', to: 'weathers#historical_max'
  get '/weather/historical/min', to: 'weathers#historical_min'
  get '/weather/historical/avg', to: 'weathers#historical_avg'
  get '/weather/by_time', to: 'weathers#by_time'
end
