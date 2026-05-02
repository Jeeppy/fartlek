# frozen_string_literal: true

module Strava
  class Client
    BASE_URL = "https://www.strava.com/api/v3"

    class ApiError < StandardError; end
    class RateLimitError < ApiError; end

    def initialize(credential)
      @credential = credential
    end

    def athlete
      get("athlete")
    end

    def activities(params = {})
      get("athlete/activities", params)
    end

    def activity(id)
      get("activities/#{id}")
    end

    # À toi de jouer :
    # - #athlete
    # - #activities(per_page: 30, after: nil)
    # - #activity(id)
    # - une méthode privée #get(path, params = {}) qui gère les erreurs

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |f|
        f.request :url_encoded
        f.headers["Authorization"] = "Bearer #{@credential.access_token}"
      end
    end

    def get(path, params = {})
      response = connection.get(path, params)

      case response.status
      when 200
        JSON.parse(response.body)
      when 429
        raise RateLimitError, "Rate limit exceeded"
      else
        raise ApiError, "Strava API error: #{response.status}"
      end
    end
  end
end
