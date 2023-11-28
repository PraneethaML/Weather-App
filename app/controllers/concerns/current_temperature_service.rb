module CurrentTemperatureService
  extend ActiveSupport::Concern

  CACHE_EXPIRY = 30.minutes

  private 

  def get_temperature_by_zipcode(zipcode, country)
    initialize_service(zipcode, country)
    cache_exists = cache_exist?
    result = fetch_from_cache { fetch_temperature_from_api }

    result[:cached] = cache_exists
    result
  end

  def initialize_service(zipcode, country)
    @zipcode = zipcode
    @country = country.upcase
    @cache_key = "temperature_#{@zipcode}_#{@country}"
  end

  def cache_exist?
    Rails.cache.exist?(@cache_key)
  end

  def fetch_from_cache(&block)
    Rails.cache.fetch(@cache_key, expires_in: CACHE_EXPIRY, &block)
  end

  # Retrieve the current temperature based on the provided zipcode and country parameters using external api
  def fetch_temperature_from_api
    response = { temperature: nil, error: nil, status: nil }
    
    begin
      data = OpenWeatherConfig.client.current_zip(@zipcode, @country)
      response[:temperature] = {
        current: data.main.temp_c,
        max: data.main.temp_max_c,
        min: data.main.temp_min_c
      }
    rescue Faraday::ResourceNotFound => e
      handle_error(response, e, 'Sorry! We currently do not have the data for these parameters.')
    rescue Faraday::UnauthorizedError => e
      handle_error(response, e, 'Unauthorized - API token is missing or invalid')
    rescue Faraday::TooManyRequestsError => e
      handle_error(response, e, 'Too Many Requests - Key quota exceeded')
    rescue Faraday::ConnectionFailed => e
      handle_error(response, e, 'Connection Failed')
    rescue StandardError => e
      handle_error(response, e, 'Sorry, we encountered an unexpected error. Please try later.')
    ensure
      puts "Response after external API call: #{response}"
      return response
    end
  end

  def handle_error(response, error, error_message)
    puts "Handling error: #{error.response}"
    status = error.response[:body]['cod'] || 503
    response[:error] = error_message
    response[:status] = status
  end
end
  