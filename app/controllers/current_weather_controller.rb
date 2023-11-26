class CurrentWeatherController < ApplicationController
    before_action :validate_params, only: :get_temperature

    def index
        render 'index'
    end

    def get_temperature
        if params[:zipcode].present?
            @temperature = get_temperature_by_zipcode(weather_params[:zipcode], weather_params[:country])
        else
            render json: { error: 'Invalid input' }, status: :bad_request
            return
        end
        render 'index'
    end

    private

     # fetch temperature based on zipcode and country
    def get_temperature_by_zipcode(zipcode, country)
        
        data = OpenWeatherConfig.client.current_zip(zipcode, country)
        temperature = {
            current: data.main.temp_c,
            max: data.main.temp_max_c,
            min: data.main.temp_min_c
        }
    end

    def validate_params
        unless (weather_params[:zipcode].present? && weather_params[:country].present?)
            render json: { error: 'Zipcode & Country must be present' }, status: :bad_request
        end
    end

    def weather_params
        params.permit(:zipcode, :country, :lat, :long)
    end
end
