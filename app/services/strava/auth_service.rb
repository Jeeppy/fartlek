# frozen_string_literal: true

module Strava
  class AuthService
    BASE_URL = "https://www.strava.com/oauth"
    CLIENT_ID = ENV.fetch("STRAVA_CLIENT_ID", "your_client_id")
    CLIENT_SECRET = ENV.fetch("STRAVA_CLIENT_SECRET", "your_client_secret")
    REDIRECT_URI = ENV.fetch("STRAVA_REDIRECT_URI", "http://localhost:3000/strava/callback")

    def self.authorize_url
      params = {
        client_id: CLIENT_ID,
        redirect_uri: REDIRECT_URI,
        response_type: "code",
        scope: "read,activity:read_all"
      }
      "#{BASE_URL}/authorize?#{URI.encode_www_form(params)}"
    end

    def self.exchange_token(code)
      response = Faraday.post("#{BASE_URL}/token") do |req|
        req.body = {
          client_id: CLIENT_ID,
          client_secret: CLIENT_SECRET,
          code: code,
          grant_type: "authorization_code"
        }
      end

      JSON.parse(response.body)
    end

    def self.refresh_token(refresh_token)
      response = Faraday.post("#{BASE_URL}/token") do |req|
        req.body = {
          client_id: CLIENT_ID,
          client_secret: CLIENT_SECRET,
          refresh_token: refresh_token,
          grant_type: "refresh_token"
        }
      end

      JSON.parse(response.body)
    end
  end
end
