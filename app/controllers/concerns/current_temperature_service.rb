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
  
    def fetch_temperature_from_api
      begin
        data = OpenWeatherConfig.client.current_zip(@zipcode, @country)
        temperature = {
          current: data.main.temp_c,
          max: data.main.temp_max_c,
          min: data.main.temp_min_c
        }
        { temperature: temperature }
      rescue StandardError => e
        { temperature: nil }
      end
    end
  end
  