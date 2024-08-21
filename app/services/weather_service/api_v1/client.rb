# frozen_string_literal: true

require 'faraday'


module WeatherService
  WEATHER_API_URL = ENV["WEATHER_API_URL"]
  WEATHER_API_KEY = ENV["WEATHER_API_KEY"]

  module ApiV1
    class Client
      def get_location_key
        url = build_url("/locations/v1/cities/search")
        params = global_params.merge({
          q: "Moscow Russia" # HARDCODED
        })

        json_data = Rails.cache.fetch([url, params], expires: 24.hour) do
          response = handle_response(Faraday.get(url, params))
          json_data = response.body
        end

        return JSON.load(json_data).first['Key'].to_i
      end

      def get_current_temperature
        location_id = get_location_key
        url = build_url("/currentconditions/v1/#{location_id}")

        json_data = Rails.cache.fetch([url, global_params], expires: 1.hour) do
          response = handle_response(Faraday.get(url, global_params))
          json_data = response.body
        end

        data = JSON.load(json_data).first

        return {
          epoch_time: data['EpochTime'],
          value: data['Temperature']['Metric']['Value'],
          unit: data['Temperature']['Metric']['Unit'],
          location_id: location_id,
        }
      end

      def get_historical_temperature
        location_id = get_location_key
        url = build_url("/currentconditions/v1/#{location_id}/historical/24")

        json_data = Rails.cache.fetch([url, global_params], expires: 12.hour) do
          response = handle_response(Faraday.get(url, global_params))
          json_data = response.body
        end

        return JSON.load(json_data).map do |data|
          {
            epoch_time: data['EpochTime'],
            value: data['Temperature']['Metric']['Value'],
            unit: data['Temperature']['Metric']['Unit'],
            location_id: location_id,
          }
        end
      end

      def get_max_temperature
        get_historical_temperature.max_by { |temperature| temperature[:value] }
      end

      def get_min_temperature
        get_historical_temperature.min_by { |temperature| temperature[:value] }
      end

      def get_avg_temperature
        historical_temperature = get_historical_temperature
        avg_temp = (historical_temperature.sum { |temperature| temperature[:value] } / historical_temperature.size).round(1)
        
        return {
          value: avg_temp,
          unit: historical_temperature.first[:unit],
          location_id: historical_temperature.first[:location_id],
        }
      end

      private

      def handle_response(response)
        message = { message: response.body, status: response.status }.to_json
        case response.status
        when 400
          raise Exceptions::BadRequest.new(message)
        when 401
          raise Exceptions::AuthorizationFailed.new(message)
        when 403
          raise Exceptions::PermissionsDenied.new(message)
        when 404
          raise Exceptions::NotFound.new(message)
        when 500
          raise Exceptions::ExternalServerError.new(message)
        when 503
          raise Exceptions::ServiceUnavailable.new(message)
        else
          return response
        end
      end

      def global_params
        { apikey: WeatherService::WEATHER_API_KEY }
      end

      def build_url(path)
        WeatherService::WEATHER_API_URL + path
      end
    end
  end
end
