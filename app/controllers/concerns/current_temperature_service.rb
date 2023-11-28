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
    response = { temperature: nil }
    begin
      data = OpenWeatherConfig.client.current_zip(@zipcode, @country)
      response[:temperature] = {
        current: data.main.temp_c,
        max: data.main.temp_max_c,
        min: data.main.temp_min_c
      }
    rescue Faraday::ResourceNotFound, Faraday::UnauthorizedError, Faraday::TooManyRequestsError => e
      puts "Handling error: #{e.response}"
      error_message = case e
                      when Faraday::ResourceNotFound
                        "Not Found - Data with requested parameters does not exist"
                      when Faraday::Unauthorized
                        "Unauthorized - API token is missing or invalid"
                      when Faraday::TooManyRequestsError
                        "Too Many Requests - Key quota exceeded"
                      end
      status = e.response[:body]['cod'] || 503
      error_msg = "#{error_message}. Status: #{status}"
    rescue Faraday::ConnectionFailed => e
      puts "Handling connection failure: #{e.response}"
      error_msg = 'Connection Failed'
      status = e.response[:body]['cod'] || 503
    rescue StandardError => e
      # TODO: Invalid api key is also giving in standard error
      puts "Handling standard error: #{e.response}"
      error_msg = e.message
      status = e.response[:body]['cod'] || 503
    ensure
      response[:error] = error_msg
      response[:status] = status
      puts "Response after external api is #{response}"
      return response  
    end
  end    
end
  