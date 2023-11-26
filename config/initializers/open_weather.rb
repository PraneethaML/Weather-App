# config/initializers/open_weather.rb

OpenWeather.configure do |config|
    config.api_key = Rails.application.credentials.open_weather_api_key
end
  
class OpenWeatherConfig
    class_attribute :client

    self.client = OpenWeather::Client.new(api_key: OpenWeather.configure.api_key)
end
