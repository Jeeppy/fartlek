# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strava::AuthService do
  describe ".authorize_url" do
    it "returns a Strava OAuth URL" do
      url = described_class.authorize_url
      expect(url).to include("www.strava.com/oauth/authorize")
      expect(url).to include("response_type=code")
      expect(url).to include("scope=read")
      expect(url).to include("activity%3Aread_all")
    end
  end

  describe ".exchange_token" do
    it "exchanges code for tokens" do
      body = file_fixture("strava/token_response.json").read
      stub_request(:post, "https://www.strava.com/oauth/token")
        .to_return(status: 200, body: body)

      result = described_class.exchange_token("auth_code_123")
      expect(result["access_token"]).to eq("new_access_token_abc123")
      expect(result["athlete"]["id"]).to eq(12_345_678)
    end
  end

  describe ".refresh_token" do
    it "refreshes an expired token" do
      body = file_fixture("strava/token_response.json").read
      stub_request(:post, "https://www.strava.com/oauth/token")
        .to_return(status: 200, body: body)

      result = described_class.refresh_token("old_refresh_token")
      expect(result["access_token"]).to eq("new_access_token_abc123")
    end
  end
end
