# frozen_string_literal: true

require "rails_helper"

RSpec.describe StravaActivityImportJob do
  let(:user) { create(:user) }
  let!(:credential) { create(:strava_credential, user: user) }

  before do
    stub_request(:get, %r{www.strava.com/api/v3/activities/\d+})
      .to_return(status: 200, body: file_fixture("strava/activity.json").read)
  end

  describe "#perform" do
    it "imports a single activity from Strava" do
      expect do
        described_class.new.perform(user.id, 9_876_543_210)
      end.to change(Activity, :count).by(1)
    end

    it "skips if activity already exists" do
      create(:activity, user: user, strava_id: 9_876_543_210)
      expect do
        described_class.new.perform(user.id, 9_876_543_210)
      end.not_to change(Activity, :count)
    end

    it "creates laps" do
      described_class.new.perform(user.id, 9_876_543_210)
      expect(ActivityLap.count).to eq(2)
    end
  end
end
