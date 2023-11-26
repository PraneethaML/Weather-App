Rails.application.routes.draw do
 # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'current_weather#index'
  post '/current_weather/get_temperature', to: 'current_weather#get_temperature', as: :get_temperature
end
