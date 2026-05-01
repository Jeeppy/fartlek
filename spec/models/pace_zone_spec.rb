# frozen_string_literal: true

require "rails_helper"

RSpec.describe PaceZone do
  subject(:zone) { build(:pace_zone) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:zone_number) }
    it { is_expected.to validate_inclusion_of(:zone_number).in_range(1..7) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:min_pace_seconds_per_km) }
    it { is_expected.to validate_presence_of(:max_pace_seconds_per_km) }

    context "when max <= min" do
      before { zone.max_pace_seconds_per_km = zone.min_pace_seconds_per_km }

      it "is invalid" do
        expect(zone).not_to be_valid
        expect(zone.errors[:max_pace_seconds_per_km]).to be_present
      end
    end

    context "with uniqueness scoped to user" do
      subject { create(:pace_zone) }

      it { is_expected.to validate_uniqueness_of(:zone_number).scoped_to(:user_id) }
    end
  end

  describe ".generate_defaults" do
    let(:user) { create(:user) }

    it "creates 7 zones" do
      expect { described_class.generate_defaults(user) }.to change(described_class, :count).by(7)
    end

    it "does not duplicate existing zones" do
      described_class.generate_defaults(user)
      expect { described_class.generate_defaults(user) }.not_to change(described_class, :count)
    end
  end

  describe "#min_pace_formatted" do
    it "formats pace" do
      zone.min_pace_seconds_per_km = 330
      expect(zone.min_pace_formatted).to eq("5:30")
    end
  end

  describe "#max_pace_formatted" do
    it "formats pace" do
      zone.max_pace_seconds_per_km = 300
      expect(zone.max_pace_formatted).to eq("5:00")
    end
  end
end
