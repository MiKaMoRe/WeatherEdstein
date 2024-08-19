module WeatherService
  module ApiV1
    module Exceptions
      class BadRequest < StandardError; end           # 400
      class AuthorizationFailed < StandardError; end  # 401
      class PermissionsDenied < StandardError; end    # 403
      class NotFound < StandardError; end             # 404
      class ExternalServerError < StandardError; end  # 500
    end
  end
end
