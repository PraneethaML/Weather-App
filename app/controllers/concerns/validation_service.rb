module ValidationService
    extend ActiveSupport::Concern
  
    private
  
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
  
    # returns false if zipcode consists of non digits
    def valid_zipcode?(zipcode)
      /\A\d+\z/.match?(zipcode.to_s)
    end
  
    # returns false if country contains digits 
    def valid_country_code?(country)
      /\A[A-Za-z]+\z/.match?(country)
    end
  
    # checks if the country is servicable
    def valid_zipcode_in_country?(zipcode, country)
      country = country.upcase
      valid = true
      error_message = ''
      valid_zipcodes_for_country = {
        'US' => /\A\d{5}\z/,
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
  
      [valid, error_message]
    end
  end
  