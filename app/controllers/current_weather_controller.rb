class CurrentWeatherController < ApplicationController
  include ValidationService
  include CurrentTemperatureService
  # Before calling the 'get_temperature' action, validate the parameters using the 'validate_params' method.
  before_action :validate_params, only: :get_temperature

  def index
    render 'index'
  end

  def get_temperature
    result = get_temperature_by_zipcode(weather_params[:zipcode], weather_params[:country])
    @temperature = result[:temperature]
    # status_code = result[:cached] ? :not_modified : :ok
    render json: { success: true, temperature: @temperature, cached: result[:cached] }, status: :ok
  end
    
  private
  # permit only the specified parameters (:zipcode, :country).
  def weather_params
    params.permit(:zipcode, :country)
  end
end
