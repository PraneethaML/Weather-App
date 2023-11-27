module WeatherService
    extend ActiveSupport::Concern
  
    included do
      before_action :validate_params, only: :get_temperature
    end
  
    private
  
     # fetch temperature based on zipcode and country
    def get_temperature_by_zipcode(zipcode, country)    
        country = country.upcase
        cache_key = "temperature_#{zipcode}_#{country}"
        # Check if the cache exists before attempting to fetch
        cache_exists = Rails.cache.exist?(cache_key)
        # fetch the result from the cache
        result = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
            # This block is only executed if the cache is empty or expired
            begin
                data = OpenWeatherConfig.client.current_zip(zipcode, country)
                temperature = {
                    current: data.main.temp_c,
                    max: data.main.temp_max_c,
                    min: data.main.temp_min_c
                }
                {temperature: temperature}
            rescue StandardError => e
                {temperature: nil} 
                
            end
        end

        result[:cached] = cache_exists
        result
    end
  
    def validate_params
        unless (weather_params[:zipcode].present? && weather_params[:country].present?)
            return render_json_error('Zipcode & Country must be present')
        end
        
        unless valid_zipcode?(weather_params[:zipcode])
            return render_json_error('Invalid Zipcode. Zipcode should be a number')
        end
        
        unless valid_country_code?(weather_params[:country])
            return render_json_error('Invalid Country Code. Country code should be a string of alphabets')
        end
        
        zipcode_country_validity, error_message = valid_zipcode_in_country?(weather_params[:zipcode], weather_params[:country])
        return render_json_error(error_message) unless zipcode_country_validity    
    end

    def render_json_error(message)
        render json: { success: false, error: message }, status: :unprocessable_entity
    end
  
    def valid_zipcode?(zipcode)
        /\A\d+\z/.match?(zipcode.to_s)
    end
  
    def valid_country_code?(country)
        /\A[A-Za-z]+\z/.match?(country)
    end
  
    def valid_zipcode_in_country?(zipcode, country)
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
  end
  