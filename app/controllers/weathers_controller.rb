class WeathersController < ApplicationController
  rescue_from 'WeatherService::ApiV1::Exceptions::BadRequest', with: :handle_error
  rescue_from 'WeatherService::ApiV1::Exceptions::AuthorizationFailed', with: :handle_error
  rescue_from 'WeatherService::ApiV1::Exceptions::PermissionsDenied', with: :handle_error
  rescue_from 'WeatherService::ApiV1::Exceptions::NotFound', with: :handle_error
  rescue_from 'WeatherService::ApiV1::Exceptions::ExternalServerError', with: :handle_error

  def current
    current_temperature = weather_service.get_current_temperature

    unless Temperature.where(
      epoch_time: current_temperature[:epoch_time],
      external_location_id: current_temperature[:location_id],
    ).any?
      Temperature.create!(
        metric_value: current_temperature[:value],
        metric_unit: current_temperature[:unit],
        epoch_time: current_temperature[:epoch_time],
        external_location_id: current_temperature[:location_id],
      )
    end

    render json: current_temperature
  end

  def historical
    historical_temperature = weather_service.get_historical_temperature

    selected_temp = historical_temperature.select do |temperature|
      Temperature.where(
        epoch_time: temperature[:epoch_time],
        external_location_id: temperature[:location_id],
      ).empty?
    end

    Temperature.create!(
      selected_temp.map do |temperature|
        {
          metric_value: temperature[:value],
          metric_unit: temperature[:unit],
          epoch_time: temperature[:epoch_time],
          external_location_id: temperature[:location_id],
        }
      end
    ) if selected_temp.any?

    render json: historical_temperature
  end

  def historical_max
    render json: weather_service.get_max_temperature
  end

  def historical_min
    render json: weather_service.get_min_temperature
  end

  def historical_avg
    render json: weather_service.get_avg_temperature
  end

  def by_time
    render json: find_temperature
  end

  private

  def handle_error(exception)
    message = JSON.parse(exception.message)
    render json: { message: message['message'] }, status: message['status']
  end

  def find_temperature
    Temperature.where(search_params).first
  end

  def search_params
    params.permit(:epoch_time)
  end

  def weather_service
    @weather_service ||= ::WeatherService::ApiV1::Client.new
  end
end
