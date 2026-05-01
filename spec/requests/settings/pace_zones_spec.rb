# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Settings::PaceZones" do
  let(:user) { create(:user) }

  before { login_as user }

  describe "GET /settings/pace_zones" do
    it "renders the index" do
      get settings_pace_zones_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /settings/pace_zones/generate" do
    it "generates default zones" do
      expect do
        post settings_generate_pace_zones_path
      end.to change(PaceZone, :count).by(7)

      expect(response).to redirect_to(settings_pace_zones_path)
    end
  end

  describe "PATCH /settings/pace_zones/:id" do
    before { PaceZone.generate_defaults(user) }

    let(:zone) { user.pace_zones.first }

    it "updates the zone" do
      patch settings_pace_zone_path(zone), params: {
        pace_zone: { name: "Easy jog" }
      }
      expect(response).to redirect_to(settings_pace_zones_path)
      expect(zone.reload.name).to eq("Easy jog")
    end
  end
end
