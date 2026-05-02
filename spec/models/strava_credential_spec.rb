# frozen_string_literal: true

require "rails_helper"

RSpec.describe StravaCredential do
  subject(:credential) { build(:strava_credential) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:strava_athlete_id) }
    it { is_expected.to validate_presence_of(:access_token) }
    it { is_expected.to validate_presence_of(:refresh_token) }
    it { is_expected.to validate_presence_of(:expires_at) }

    context "with uniqueness on user" do
      subject { create(:strava_credential) }

      it { is_expected.to validate_uniqueness_of(:user_id) }
    end
  end

  describe "#expired?" do
    it "returns true when expires_at is in the past" do
      credential = build(:strava_credential, :expired)
      expect(credential).to be_expired
    end

    it "returns false when expires_at is in the future" do
      expect(credential).not_to be_expired
    end
  end

  describe "#refresh_if_expired!" do
    let(:credential) { create(:strava_credential, :expired) }

    it "calls Strava::AuthService.refresh_token when expired" do
      allow(Strava::AuthService).to receive(:refresh_token).and_return(
        "access_token" => "new_token",
        "refresh_token" => "new_refresh",
        "expires_at" => 6.hours.from_now.to_i
      )

      credential.refresh_if_expired!
      expect(credential.reload.access_token).to eq("new_token")
    end

    it "does nothing when not expired" do
      credential = create(:strava_credential)
      expect(Strava::AuthService).not_to receive(:refresh_token)
      credential.refresh_if_expired!
    end
  end
end
