class CurrentWeatherController < ApplicationController
    before_action :validate_params, only: :get_temperature

    def index
        render 'index'
    end

    def get_temperature
        @temperature = get_temperature_by_zipcode(weather_params[:zipcode], weather_params[:country])
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

        unless valid_zipcode?(weather_params[:zipcode])
            render json: { error: 'Invalid Zipcode. Zipcode should be a number' }, status: :bad_request
            return
        end
    
        unless valid_country_code?(weather_params[:country])
            render json: { error: 'Invalid Country Code. Country code should be string of alphabets' }, status: :bad_request
            return
        end
        zipcode_country_validity, error_message = valid_zipcode_in_country?(weather_params[:zipcode], weather_params[:country])
        unless zipcode_country_validity
            render json: { error: error_message }, status: :bad_request
            return
        end
    end
      
      def valid_zipcode?(zipcode)
        /\A\d+\z/.match?(zipcode.to_s)
      end
      
      def valid_country_code?(country)
        /\A[A-Za-z]+\z/.match?(country)
      end
      
      def valid_zipcode_in_country?(zipcode, country)
        country = country.upcase
        valid = true
        error_message = ''
        valid_zipcodes_for_country = {
          'US' => /\A\d{5}\z/,
          'CA' => /\A[ABCEGHJKLMNPRSTVXY]\d[A-Z] \d[A-Z]\d\z/,
          'IN' => /\A\d{6}\z/
        }

        validation_pattern = valid_zipcodes_for_country[country]

        if !validation_pattern.present?
            valid = false
            error_message = 'Sorry! We currently do not provide services to this country'
        elsif !validation_pattern.match?(zipcode.to_s)
            valid = false
            error_message = 'Invalid zipcode. There is no zipcode with the given value in this country.'
        end

        [valid ,error_message]
      end
      

    def weather_params
        params.permit(:zipcode, :country)
    end
end
