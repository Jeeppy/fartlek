# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Settings::HeartRateZones" do
  let(:user) { create(:user) }

  before { login_as user }

  describe "GET /settings/heart_rate_zones" do
    it "renders the index" do
      get settings_heart_rate_zones_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /settings/heart_rate_zones/generate" do
    it "generates default zones" do
      expect do
        post settings_generate_heart_rate_zones_path
      end.to change(HeartRateZone, :count).by(5)

      expect(response).to redirect_to(settings_heart_rate_zones_path)
    end
  end

  describe "PATCH /settings/heart_rate_zones/:id" do
    before { HeartRateZone.generate_defaults(user) }

    let(:zone) { user.heart_rate_zones.first }

    it "updates the zone" do
      patch settings_heart_rate_zone_path(zone), params: {
        heart_rate_zone: { name: "Recovery", min_bpm: 90, max_bpm: 110 }
      }
      expect(response).to redirect_to(settings_heart_rate_zones_path)
      expect(zone.reload.name).to eq("Recovery")
    end
  end
end
