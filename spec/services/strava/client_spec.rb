# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strava::Client do
  let(:credential) { create(:strava_credential) }
  let(:client) { described_class.new(credential) }

  before do
    stub_request(:any, /www.strava.com/).to_return(status: 200, body: "{}")
  end

  describe "#athlete" do
    it "fetches the authenticated athlete" do
      body = file_fixture("strava/athlete.json").read
      stub_request(:get, "https://www.strava.com/api/v3/athlete")
        .to_return(status: 200, body: body)

      result = client.athlete
      expect(result["id"]).to eq(12_345_678)
    end

    it "sends the authorization header" do
      stub = stub_request(:get, "https://www.strava.com/api/v3/athlete")
             .with(headers: { "Authorization" => "Bearer #{credential.access_token}" })
             .to_return(status: 200, body: "{}")

      client.athlete
      expect(stub).to have_been_requested
    end
  end

  describe "#activities" do
    it "fetches a list of activities" do
      body = file_fixture("strava/activities_list.json").read
      stub_request(:get, "https://www.strava.com/api/v3/athlete/activities")
        .to_return(status: 200, body: body)

      result = client.activities

      expect(result.size).to eq(2)
    end

    it "passes per_page and after params" do
      stub = stub_request(:get, "https://www.strava.com/api/v3/athlete/activities")
             .with(query: { per_page: 50, after: 1_700_000_000 })
             .to_return(status: 200, body: "[]")

      client.activities(per_page: 50, after: 1_700_000_000)
      expect(stub).to have_been_requested
    end
  end

  describe "#activity" do
    it "fetches a single activity with laps" do
      body = file_fixture("strava/activity.json").read
      stub_request(:get, "https://www.strava.com/api/v3/activities/9876543210")
        .to_return(status: 200, body: body)

      result = client.activity(9_876_543_210)
      expect(result["id"]).to eq(9_876_543_210)
      expect(result["laps"].size).to eq(2)
    end
  end

  describe "error handling" do
    it "raises Strava::Client::ApiError on 401" do
      stub_request(:get, "https://www.strava.com/api/v3/athlete")
        .to_return(status: 401, body: '{"message":"Authorization Error"}')

      expect { client.athlete }.to raise_error(Strava::Client::ApiError, /401/)
    end

    it "raises Strava::Client::RateLimitError on 429" do
      stub_request(:get, "https://www.strava.com/api/v3/athlete")
        .to_return(status: 429, body: '{"message":"Rate Limit Exceeded"}')

      expect { client.athlete }.to raise_error(Strava::Client::RateLimitError)
    end
  end
end
