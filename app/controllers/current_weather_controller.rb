class CurrentWeatherController < ApplicationController
    include WeatherService
    def index
        render 'index'
    end

    def get_temperature
        result = get_temperature_by_zipcode(weather_params[:zipcode], weather_params[:country])
        @temperature = result[:temperature]
        flash.now[:notice] = 'Temperature retrieved successfully!' if @temperature.present?
        if result[:cached]
            flash.now[:notice] = "Result served from cache"
        end
        render 'index'
    end

    private

    def weather_params
        params.permit(:zipcode, :country)
    end
end
