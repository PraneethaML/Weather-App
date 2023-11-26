class CurrentWeatherController < ApplicationController
    before_action :validate_params, only: :get_temperature

    def index
        render 'index'
    end

    def get_temperature
        @temperature = get_temperature_by_zipcode(weather_params[:zipcode], weather_params[:country])
        flash[:notice] = 'Temperature retrieved successfully!' if @temperature.present?
        render 'index'
    end

    private

     # fetch temperature based on zipcode and country
    def get_temperature_by_zipcode(zipcode, country)    
        begin
            data = OpenWeatherConfig.client.current_zip(zipcode, country)
            temperature = {
                current: data.main.temp_c,
                max: data.main.temp_max_c,
                min: data.main.temp_min_c
            }
        rescue StandardError => e
            puts "Error in getting temperature by zipcode------------------------: #{e}"
            temperature = nil 
        end
        
    end

    def validate_params
        unless (weather_params[:zipcode].present? && weather_params[:country].present?)
            flash.now[:error] = 'Zipcode & Country must be present'
            render 'index'
            return
        end
        unless valid_zipcode?(weather_params[:zipcode])
            flash.now[:error] = 'Invalid Zipcode. Zipcode should be a number'
            render 'index'
            return
          end
        
        unless valid_country_code?(weather_params[:country])
            flash.now[:error] = 'Invalid Country Code. Country code should be a string of alphabets'
            render 'index'
            return
        end
    
        zipcode_country_validity, error_message = valid_zipcode_in_country?(weather_params[:zipcode], weather_params[:country])
        unless zipcode_country_validity
            flash.now[:error] = error_message
            render 'index'
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
