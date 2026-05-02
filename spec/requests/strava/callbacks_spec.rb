# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Strava::Callbacks" do
  let(:user) { create(:user) }

  before { login_as user }

  describe "GET /strava/callback" do
    it "exchanges the code and creates a credential" do
      body = file_fixture("strava/token_response.json").read
      stub_request(:post, "https://www.strava.com/oauth/token")
        .to_return(status: 200, body: body)

      expect do
        get strava_callback_path(code: "auth_code_123")
      end.to change(StravaCredential, :count).by(1)

      expect(response).to redirect_to(settings_strava_path)
    end

    it "enqueues a sync job after connection" do
      body = file_fixture("strava/token_response.json").read
      stub_request(:post, "https://www.strava.com/oauth/token")
        .to_return(status: 200, body: body)

      expect do
        get strava_callback_path(code: "auth_code_123")
      end.to have_enqueued_job(StravaSyncJob)
    end

    it "redirects with error when code is missing" do
      get strava_callback_path
      expect(response).to redirect_to(settings_strava_path)
      expect(flash[:alert]).to be_present
    end
  end
end
