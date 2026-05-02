# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strava::SyncService do
  let(:user) do
    user = create(:user)
    create(:strava_credential, user: user)

    user
  end

  before do
    stub_request(:get, %r{www.strava.com/api/v3/athlete/activities})
      .to_return(status: 200, body: file_fixture("strava/activities_list.json").read)

    stub_request(:get, "https://www.strava.com/api/v3/activities/9876543210")
      .to_return(status: 200, body: file_fixture("strava/activity.json").read)

    activity_ride = JSON.parse(file_fixture("strava/activity.json").read)
                        .merge("id" => 9_876_543_211, "name" => "Evening Ride", "type" => "Ride", "sport_type" => "Ride")
    stub_request(:get, "https://www.strava.com/api/v3/activities/9876543211")
      .to_return(status: 200, body: activity_ride.to_json)
  end

  describe "#call" do
    subject(:service) { described_class.new(user) }

    it "creates activities from Strava" do
      expect { service.call }.to change(Activity, :count).by(2)
    end

    it "skips activities that already exist" do
      create(:activity, user: user, strava_id: 9_876_543_210)
      expect { service.call }.to change(Activity, :count).by(1)
    end

    it "updates last_sync_at" do
      service.call
      expect(user.strava_credential.reload.last_sync_at).to be_present
    end

    it "creates activity laps" do
      service.call
      activity = Activity.find_by(strava_id: 9_876_543_210)
      expect(activity.activity_laps.count).to eq(2)
    end

    it "skips unsupported sport types" do
      activities = [{ "id" => 111, "type" => "Yoga", "sport_type" => "Yoga",
                      "start_date" => "2026-04-30T08:00:00Z", "elapsed_time" => 1800,
                      "distance" => 0 }]
      stub_request(:get, %r{athlete/activities})
        .to_return(status: 200, body: activities.to_json)

      expect { service.call }.not_to change(Activity, :count)
    end
  end
end
