# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Strava::Webhooks" do
  describe "GET /strava/webhooks (verification)" do
    it "responds with the hub challenge" do
      get strava_webhooks_verify_path, params: {
        "hub.mode" => "subscribe",
        "hub.challenge" => "challenge_token_123",
        "hub.verify_token" => "STRAVA_VERIFY_TOKEN"
      }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["hub.challenge"]).to eq("challenge_token_123")
    end
  end

  describe "POST /strava/webhooks" do
    let(:user) { create(:user) }
    let!(:credential) { create(:strava_credential, user: user, strava_athlete_id: 12_345_678) }

    it "enqueues an import job for activity create events" do
      expect do
        post strava_webhooks_path, params: {
          object_type: "activity",
          aspect_type: "create",
          object_id: 9_876_543_210,
          owner_id: 12_345_678
        }
      end.to have_enqueued_job(StravaActivityImportJob)

      expect(response).to have_http_status(:ok)
    end

    it "ignores non-activity events" do
      expect do
        post strava_webhooks_path, params: {
          object_type: "athlete",
          aspect_type: "update",
          object_id: 12_345_678,
          owner_id: 12_345_678
        }
      end.not_to have_enqueued_job(StravaActivityImportJob)

      expect(response).to have_http_status(:ok)
    end

    it "ignores unknown athletes" do
      expect do
        post strava_webhooks_path, params: {
          object_type: "activity",
          aspect_type: "create",
          object_id: 111,
          owner_id: 99_999_999
        }
      end.not_to have_enqueued_job(StravaActivityImportJob)
    end
  end
end
