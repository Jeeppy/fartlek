# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Settings::Strava" do
  let(:user) { create(:user) }

  before { login_as user }

  describe "GET /settings/strava" do
    it "renders the strava settings page" do
      get settings_strava_path
      expect(response).to have_http_status(:ok)
    end

    it "shows connect button when no credential" do
      get settings_strava_path
      expect(response.body).to include("Connecter Strava")
    end

    it "shows connected status when credential exists" do
      create(:strava_credential, user: user)
      get settings_strava_path
      expect(response.body).to include("Connecté")
    end
  end

  describe "DELETE /settings/strava" do
    it "destroys the credential" do
      create(:strava_credential, user: user)
      expect do
        delete settings_strava_path
      end.to change(StravaCredential, :count).by(-1)

      expect(response).to redirect_to(settings_strava_path)
    end
  end

  describe "POST /settings/strava/sync" do
    it "enqueues a sync job" do
      create(:strava_credential, user: user)
      expect do
        post sync_settings_strava_path
      end.to have_enqueued_job(StravaSyncJob)

      expect(response).to redirect_to(settings_strava_path)
    end
  end
end
