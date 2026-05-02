# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strava::ActivityMapper do
  let(:user) { create(:user) }
  let(:strava_data) { JSON.parse(file_fixture("strava/activity.json").read) }

  describe "#call" do
    subject(:mapper) { described_class.new(user, strava_data) }

    it "maps Strava activity to Activity attributes" do
      attrs = mapper.call
      expect(attrs[:strava_id]).to eq(9_876_543_210)
      expect(attrs[:title]).to eq("Morning Run")
      expect(attrs[:sport]).to eq("running")
      expect(attrs[:duration_seconds]).to eq(3600)
      expect(attrs[:distance_meters]).to eq(10_000)
      expect(attrs[:elevation_gain_meters]).to eq(85)
      expect(attrs[:average_heart_rate]).to eq(148)
      expect(attrs[:max_heart_rate]).to eq(172)
      expect(attrs[:calories]).to eq(650)
    end

    it "calculates pace for running activities" do
      attrs = mapper.call
      expect(attrs[:average_pace_seconds_per_km]).to be_present
      expect(attrs[:average_pace_seconds_per_km]).to eq(360)
    end

    it "stores raw Strava data" do
      attrs = mapper.call
      expect(attrs[:strava_data]).to be_a(Hash)
      expect(attrs[:strava_data]["id"]).to eq(9_876_543_210)
    end

    it "maps Strava sport types correctly" do
      expect(described_class.map_sport("Run")).to eq("running")
      expect(described_class.map_sport("Ride")).to eq("cycling")
      expect(described_class.map_sport("Walk")).to eq("walking")
      expect(described_class.map_sport("Swim")).to eq("swimming")
      expect(described_class.map_sport("WeightTraining")).to eq("ppg")
      expect(described_class.map_sport("UnknownType")).to be_nil
    end

    it "maps laps" do
      attrs = mapper.call
      expect(attrs[:laps].size).to eq(2)
      expect(attrs[:laps].first[:lap_number]).to eq(1)
      expect(attrs[:laps].first[:distance_meters]).to eq(5000)
    end
  end
end
