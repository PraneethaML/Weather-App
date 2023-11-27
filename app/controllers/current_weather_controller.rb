class CurrentWeatherController < ApplicationController
    include WeatherService
    def index
        render 'index'
    end

    def get_temperature
        result = get_temperature_by_zipcode(weather_params[:zipcode], weather_params[:country])
        @temperature = result[:temperature]
        render json: { temperature: @temperature, cached: result[:cached] }
    end

    private

    def weather_params
        params.permit(:zipcode, :country)
    end
end
