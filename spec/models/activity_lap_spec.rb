# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActivityLap do
  subject(:lap) { build(:activity_lap) }

  describe "associations" do
    it { is_expected.to belong_to(:activity) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:lap_number) }
    it { is_expected.to validate_numericality_of(:lap_number).is_greater_than(0) }
  end

  describe ".ordered" do
    it "orders by lap_number" do
      activity = create(:activity)
      lap3 = create(:activity_lap, activity: activity, lap_number: 3)
      lap1 = create(:activity_lap, activity: activity, lap_number: 1)
      lap2 = create(:activity_lap, activity: activity, lap_number: 2)
      expect(described_class.ordered).to eq([lap1, lap2, lap3])
    end
  end

  describe "#pace_formatted" do
    it "formats pace" do
      lap.average_pace_seconds_per_km = 300
      expect(lap.pace_formatted).to eq("5:00 /km")
    end

    it "returns nil when pace is nil" do
      lap.average_pace_seconds_per_km = nil
      expect(lap.pace_formatted).to be_nil
    end
  end
end
